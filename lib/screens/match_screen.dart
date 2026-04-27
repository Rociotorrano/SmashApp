import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pantheon/models/user_model.dart';
import 'package:pantheon/services/auth_service.dart';
import 'package:pantheon/theme.dart';
import 'package:pantheon/services/ad_service.dart';

class MatchScreen extends StatelessWidget {
  final UserModel matchedUser;
  final String? connectionId;

  const MatchScreen({
    super.key,
    required this.matchedUser,
    this.connectionId,
  });

  void _onClose(BuildContext context) {
    Navigator.of(context).pop();
    AdService().showInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E0A),
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo oscuro con patrón de líneas horizontales muy sutiles
            Container(
              color: const Color(0xFF0A0E0A),
              child: Stack(
                children: List.generate(
                  MediaQuery.of(context).size.height ~/ 4,
                  (index) => Positioned(
                    top: index * 4.0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1,
                      color: AppColors.neonGreen.withValues(alpha: 0.03),
                    ),
                  ),
                ),
              ),
            ),
            // Sutil gradiente superior para el texto
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.0,
                  colors: [
                    AppColors.neonGreen.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Botón de cerrar (X)
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => _onClose(context),
              ),
            ),
            // Contenido principal
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1),
                // Texto "IT'S A MATCH"
                Text(
                  "IT'S A\nMATCH",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 60),
                // Fotos de usuarios (círculos lado a lado con borde blanco fino)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Consumer<AuthService>(
                    builder: (context, auth, _) {
                      final currentUser = auth.currentUser;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildUserAvatar(currentUser?.profileImageUrl),
                          const SizedBox(width: 24),
                          _buildUserAvatar(matchedUser.profileImageUrl),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                // Nombre del usuario (como en la imagen: "Rocio")
                Text(
                  matchedUser.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Mensaje informativo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    '¿Coordinamos un partido?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // Botones (Estilo cápsula alargada como en la imagen)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      // Botón principal "ENVIAR MENSAJE"
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            final path = connectionId != null
                                ? '/chat/${matchedUser.id}?connectionId=$connectionId'
                                : '/chat/${matchedUser.id}';
                            context.push(path, extra: matchedUser);
                            AdService().showInterstitialAd();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFFC7FF00), // Verde-amarillo neon como en la imagen
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'ENVIAR MENSAJE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Texto secundario "Seguir buscando"
                      TextButton(
                        onPressed: () => _onClose(context),
                        child: Text(
                          'Seguir buscando',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String? imageUrl) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 2,
        ),
        image: imageUrl != null && imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: (imageUrl == null || imageUrl.isEmpty)
          ? Icon(
              Icons.person,
              size: 65,
              color: Colors.white.withValues(alpha: 0.3),
            )
          : null,
    );
  }
}
