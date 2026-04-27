import 'package:flutter/foundation.dart';
import 'package:pantheon/models/chat_model.dart';
import 'package:pantheon/models/user_model.dart';
import 'package:pantheon/services/api_service.dart';

class ChatService extends ChangeNotifier {
  List<ConnectionModel> _connections = [];
  List<ConnectionModel> get connections => _connections;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadConnections() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().get('/conexiones', queryParameters: {
        'page': 1,
        'limit': 50,
      });

      if (response.data['exito'] == true) {
        final List data = response.data['datos']['conexiones'];
        final serverConnections =
            data.map((json) => ConnectionModel.fromJson(json)).toList();

        // Eliminar las temporales que ya están en el servidor (buscando por el ID del otro usuario)
        _connections.removeWhere((c) =>
            c.isTemporary &&
            serverConnections.any((sc) => sc.otherUser.id == c.otherUser.id));

        // Mantener las temporales restantes
        final remainingTemporaries = _connections.where((c) => c.isTemporary);

        _connections = [...remainingTemporaries, ...serverConnections];
      }
    } catch (e) {
      debugPrint('Error loading connections: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addTemporaryConnection(String? id, UserModel otherUser) {
    // Si ya existe una conexión con este usuario (real o temporal), no hacemos nada
    if (_connections.any((c) => c.otherUser.id == otherUser.id)) return;

    // Generar un ID temporal si no tenemos uno real
    final effectiveId = id ?? 'temp_${otherUser.id}';

    final newConn = ConnectionModel(
      id: effectiveId,
      user1Id: 'me',
      user2Id: otherUser.id,
      createdAt: DateTime.now(),
      otherUser: otherUser,
      lastMessage: null,
      isTemporary: true,
    );

    _connections.insert(0, newConn);
    notifyListeners();
  }

  Future<void> markRead(String connectionId) async {
    try {
      await ApiService().post('/mensajes/$connectionId/marcar-leidos');
    } catch (e) {
      debugPrint('Error marking read: $e');
    }
  }

  String? findConnectionId(String userId) {
    try {
      final conn = _connections.firstWhere(
        (c) => c.otherUser.id == userId,
      );
      return conn.id;
    } catch (e) {
      return null;
    }
  }

  Future<List<MessageModel>> getMessages(String connectionId) async {
    try {
      final response =
          await ApiService().get('/mensajes/$connectionId', queryParameters: {
        'page': 1,
        'limit': 100,
      });

      if (response.data['exito'] == true) {
        final List data = response.data['datos']['mensajes'];
        // Reverse if API returns newest first but UI needs oldest first?
        // Typically chat APIs return newest first (paginated).
        // Flutter typical Chat UI (e.g. standard ListView with reverse:true) expects newest at index 0.
        // If getting older messages (pagination), we might need to handle list order.
        // Use standard mapping for now.
        return data.map((json) => MessageModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading messages: $e');
      return [];
    }
  }

  Future<MessageModel?> sendMessage(String connectionId, String content) async {
    try {
      final response =
          await ApiService().post('/mensajes/$connectionId/enviar', data: {
        'mensaje': content,
      });

      if (response.data['exito'] == true) {
        // El backend devuelve { datos: { id } }
        final String messageId = response.data['datos']['id'].toString();

        // Construir modelo local para evitar recargar toda la lista
        String receiverId = '';
        try {
          final conn = _connections.firstWhere((c) => c.id == connectionId);
          receiverId = conn.otherUser.id;
        } catch (_) {}

        return MessageModel(
          id: messageId,
          connectionId: connectionId,
          senderId: 'me', // El UI lo reconoce como propio
          receiverId: receiverId,
          content: content,
          sentAt: DateTime.now(),
          isRead: false,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return null;
    }
  }
}
