import 'package:flutter/material.dart';
import 'package:pantheon/models/user_model.dart';
import 'package:pantheon/services/user_service.dart';
import 'package:pantheon/theme.dart';
import 'package:provider/provider.dart';
import 'package:pantheon/services/chat_service.dart';
import 'package:pantheon/screens/match_screen.dart';

class FindPlayersScreen extends StatefulWidget {
  const FindPlayersScreen({super.key});

  @override
  State<FindPlayersScreen> createState() => _FindPlayersScreenState();
}

class _FindPlayersScreenState extends State<FindPlayersScreen>
    with SingleTickerProviderStateMixin {
  List<UserModel> _players = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadPlayers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    setState(() => _isLoading = true);

    // We don't need currentUserId to exclude, backend handles it via token + excludeConnected flag
    final players = await UserService.searchUsers(excludeConnected: true);
    setState(() {
      _players = players;
      _isLoading = false;
    });
  }

  Future<void> _handleLike() async {
    if (_currentIndex < _players.length) {
      final likedPlayer = _players[_currentIndex];

      // Enviar solicitud de contacto
      final result = await UserService.requestContact(likedPlayer.id);

      if (mounted) {
        if (result['success'] == true) {
          final connectionId = result['connectionId']?.toString();
          final chatService = context.read<ChatService>();

          // Insertar localmente para que aparezca instantáneamente en la pestaña de Chat
          chatService.addTemporaryConnection(connectionId, likedPlayer);

          // Mostrar pantalla de Match
          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            barrierLabel: 'Match',
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, anim1, anim2) {
              return MatchScreen(
                matchedUser: likedPlayer,
                connectionId: result['connectionId'],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'No se pudo conectar'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    _nextCard();
  }

  void _handleDislike() {
    _nextCard();
  }

  void _nextCard() {
    if (_currentIndex < _players.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showNoMorePlayers();
    }
  }

  void _onSwipeComplete(bool isRight) {
    if (isRight) {
      _handleLike();
    } else {
      _handleDislike();
    }
  }

  void _showNoMorePlayers() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay más jugadores disponibles')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlueBackground,
      appBar: AppBar(
        title: const Text(
          'Jugadores para conectar',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.deepBlueBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _players.isEmpty
              ? Center(
                  child: Text(
                    'No hay jugadores disponibles',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: _currentIndex < _players.length
                              ? SwipeablePlayerCard(
                                  key: ValueKey(_currentIndex),
                                  player: _players[_currentIndex],
                                  onSwipeComplete: _onSwipeComplete,
                                )
                              : const SizedBox(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ActionButton(
                              icon: Icons.close,
                              color: Colors.white,
                              backgroundColor: Colors.red,
                              onPressed: _handleDislike,
                            ),
                            _ActionButton(
                              icon: Icons.sports_tennis,
                              color: Colors.white,
                              backgroundColor: Colors.green,
                              onPressed: _handleLike,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class SwipeablePlayerCard extends StatefulWidget {
  final UserModel player;
  final Function(bool isRight) onSwipeComplete;

  const SwipeablePlayerCard({
    super.key,
    required this.player,
    required this.onSwipeComplete,
  });

  @override
  State<SwipeablePlayerCard> createState() => _SwipeablePlayerCardState();
}

class _SwipeablePlayerCardState extends State<SwipeablePlayerCard>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    // Starting drag gesture
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final threshold = screenWidth * 0.3;

    if (_dragOffset.dx.abs() > threshold) {
      // Swipe complete - animate off screen
      final isRight = _dragOffset.dx > 0;
      final targetX = isRight ? screenWidth * 1.5 : -screenWidth * 1.5;

      final animation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset(targetX, _dragOffset.dy * 2),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ));

      animation.addListener(() {
        setState(() {
          _dragOffset = animation.value;
        });
      });

      _animationController.forward(from: 0).then((_) {
        widget.onSwipeComplete(isRight);
      });
    } else {
      // Spring back to center
      final animation = Tween<Offset>(
        begin: _dragOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ));

      animation.addListener(() {
        setState(() {
          _dragOffset = animation.value;
        });
      });

      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final rotation = _dragOffset.dx / screenWidth * 0.4;
    final rightIndicatorOpacity =
        (_dragOffset.dx / (screenWidth * 0.3)).clamp(0.0, 1.0);
    final leftIndicatorOpacity =
        (-_dragOffset.dx / (screenWidth * 0.3)).clamp(0.0, 1.0);

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: rotation,
          child: Stack(
            children: [
              PlayerCard(player: widget.player),
              // Right swipe indicator (Accept)
              if (_dragOffset.dx > 20)
                Positioned(
                  top: 60,
                  right: 40,
                  child: Opacity(
                    opacity: rightIndicatorOpacity,
                    child: Transform.rotate(
                      angle: -0.3,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              // Left swipe indicator (Reject)
              if (_dragOffset.dx < -20)
                Positioned(
                  top: 60,
                  left: 40,
                  child: Opacity(
                    opacity: leftIndicatorOpacity,
                    child: Transform.rotate(
                      angle: 0.3,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerCard extends StatelessWidget {
  final UserModel player;

  const PlayerCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 30.0),
                child: Column(
                  children: [
                    // Profile Image Container
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: const Color(0xFF1E293B),
                        image: player.profileImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(player.profileImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: player.profileImageUrl == null
                          ? Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.white.withValues(alpha: 0.2),
                            )
                          : null,
                    ),
                    const SizedBox(height: 24),
                    // Name and Last Name
                    Text(
                      player.name
                          .split(' ')
                          .map((str) => str.isNotEmpty
                              ? '${str[0].toUpperCase()}${str.substring(1)}'
                              : '')
                          .join(' '),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Age and Gender
                    Text(
                      '${player.age}${player.age.isNotEmpty ? " años" : ""} • ${player.gender}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Attribute Chips
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _AttributeBox(
                          icon: Icons.star_rounded,
                          label: player.category.isEmpty
                              ? 'Sin categoría'
                              : player.category,
                        ),
                        _AttributeBox(
                          icon: Icons.sports_tennis_rounded,
                          label: player.position.isEmpty
                              ? 'Posición'
                              : player.position,
                        ),
                        _AttributeBox(
                          icon: Icons.access_time_filled_rounded,
                          label: player.schedule.isEmpty
                              ? 'Sin horario'
                              : player.schedule,
                        ),
                        _AttributeBox(
                          icon: Icons.calendar_month_rounded,
                          label: '${player.yearsPlaying} años jugando',
                          isWide: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttributeBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isWide;

  const _AttributeBox({
    required this.icon,
    required this.label,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FF), // Light blue-ish tint
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        elevation: 0,
        shape: const CircleBorder(),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}
