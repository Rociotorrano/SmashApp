import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantheon/models/chat_model.dart';
import 'package:pantheon/models/user_model.dart';
import 'package:pantheon/services/auth_service.dart';
import 'package:pantheon/services/chat_service.dart';
import 'package:pantheon/services/user_service.dart';
import 'package:pantheon/theme.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String? connectionId;
  final UserModel? matchedUser; // Opcional, para carga rápida

  const ChatScreen({
    super.key,
    required this.otherUserId,
    this.connectionId,
    this.matchedUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  UserModel? _otherUser;
  UserModel? _currentUser;
  String? _connectionId;
  Timer? _retryTimer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      if (_connectionId == null) {
        _startRetryTimer();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _retryTimer?.cancel();
    super.dispose();
  }

  void _startRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final isTemporary = _connectionId?.startsWith('temp_') ?? false;

      // Si ya tenemos un ID real o no estamos montados, cancelamos
      if (!mounted || (_connectionId != null && !isTemporary)) {
        timer.cancel();
        return;
      }

      final chatService = context.read<ChatService>();
      await chatService.loadConnections();
      final newId = chatService.findConnectionId(widget.otherUserId);

      if (newId != null) {
        final newIsTemporary = newId.startsWith('temp_');
        // Si encontramos el real o cambiamos el temporal por uno real
        if (!newIsTemporary) {
          _connectionId = newId;
          timer.cancel();
          _loadMessages();
        }
      }

      if (timer.tick > 10) {
        // Un poco más de tiempo para matches frescos
        timer.cancel();
      }
    });
  }

  Future<void> _loadData() async {
    // Si ya tenemos el usuario, lo asignamos de inmediato para evitar flashes
    if (widget.matchedUser != null) {
      _otherUser = widget.matchedUser;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final chatService = context.read<ChatService>();
    _currentUser = authService.currentUser;

    if (_currentUser == null) return;

    // Intentar encontrar el ID de conexión
    _connectionId =
        widget.connectionId ?? chatService.findConnectionId(widget.otherUserId);

    if (_connectionId == null) {
      debugPrint('Connection not found in cache, refreshing connections...');
      await chatService.loadConnections();
      _connectionId = chatService.findConnectionId(widget.otherUserId);
    }

    // Obtener info del usuario si no la tenemos
    if (_otherUser == null) {
      try {
        final conn = chatService.connections
            .firstWhere((c) => c.otherUser.id == widget.otherUserId);
        _otherUser = conn.otherUser;
      } catch (_) {
        _otherUser = await UserService.getUserById(widget.otherUserId);
      }
    }

    if (_connectionId != null) {
      await _loadMessages();
    } else {
      // Si aún no hay ID, desactivamos el cargando principal
      // para que se vea la UI del chat (aunque diga "Sincronizando")
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMessages() async {
    if (_connectionId == null) return;

    final chatService = context.read<ChatService>();
    final messages = await chatService.getMessages(_connectionId!);

    // Sort logic handled in service or here. Check API return order.
    // Assuming API returns newest first or we need to respect a specific order.
    // Standard UI builds top-down. If default ListView, we want oldest first.
    // If reverse ListView, newest first.
    // Let's assume standard list for now, modify if needed.
    // If service returns raw API list, check if it's descending or ascending.

    setState(() {
      _messages = messages;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final content = _messageController.text.trim();
    final chatService = context.read<ChatService>();

    setState(() => _isSending = true);

    try {
      // 1. Asegurar ID real si es temporal. Reintentamos hasta 3 veces silenciosamente.
      int syncAttempts = 0;
      while ((_connectionId == null || _connectionId!.startsWith('temp_')) &&
          syncAttempts < 3) {
        debugPrint('Intento de sincronización $syncAttempts para envío...');
        await chatService.loadConnections();
        _connectionId = chatService.findConnectionId(widget.otherUserId);
        if (_connectionId != null && !_connectionId!.startsWith('temp_')) break;

        syncAttempts++;
        if (syncAttempts < 3) {
          await Future.delayed(const Duration(milliseconds: 800));
        }
      }

      if (_connectionId == null || _connectionId!.startsWith('temp_')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Sincronizando... por favor, intenta enviar de nuevo en un momento')));
          setState(() => _isSending = false);
        }
        return;
      }

      if (_currentUser == null || !mounted) {
        setState(() => _isSending = false);
        return;
      }

      // 2. Limpiar input y enviar
      _messageController.clear();
      var newMessage = await chatService.sendMessage(_connectionId!, content);

      // Reintento final si falla el POST del mensaje
      if (newMessage == null) {
        debugPrint('Fallo al enviar mensaje, reintento final...');
        await chatService.loadConnections();
        _connectionId = chatService.findConnectionId(widget.otherUserId);
        if (_connectionId != null) {
          newMessage = await chatService.sendMessage(_connectionId!, content);
        }
      }

      if (newMessage != null) {
        if (mounted) {
          setState(() {
            _messages.add(newMessage!);
            _isSending = false;
          });
          _scrollToBottom();
        }
      } else {
        // Restaurar texto si falló todo
        if (mounted) {
          _messageController.text = content;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Error enviando mensaje. Reintenta.')));
          setState(() => _isSending = false);
        }
      }
    } catch (e) {
      debugPrint('Error en _sendMessage: $e');
      if (mounted) {
        _messageController.text = content;
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_otherUser?.name ?? 'Chat'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _connectionId == null
                                  ? Icons.sync
                                  : Icons.sports_tennis,
                              size: 64,
                              color: AppColors.neonGreen.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _connectionId == null ||
                                      _connectionId!.startsWith('temp_')
                                  ? 'Conectando...'
                                  : '¡Nuevo match! Di hola 👋',
                              style: context.textStyles.bodyLarge?.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: AppSpacing.paddingMd,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          // Identify sender logic.
                          // If message.senderId == 'me' (placeholder) or regex match logic from backend
                          // Backend typically returns actual sender ID.
                          final isMe = message.senderId == _currentUser?.id ||
                              message.senderId == 'me';
                          return MessageBubble(
                            message: message,
                            isMe: isMe,
                          );
                        },
                      ),
          ),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.neonGreen,
                    radius: 24,
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.textDark,
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.send,
                              color: AppColors.textDark,
                              size: 22,
                            ),
                            onPressed: _sendMessage,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.neonGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          border: Border.all(
            color: isMe
                ? AppColors.neonGreen
                : AppColors.textGrey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: context.textStyles.bodyMedium?.copyWith(
                color: isMe ? AppColors.textDark : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.sentAt.hour}:${message.sentAt.minute.toString().padLeft(2, '0')}',
              style: context.textStyles.bodySmall?.copyWith(
                color: isMe
                    ? AppColors.textDark.withValues(alpha: 0.6)
                    : AppColors.textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
