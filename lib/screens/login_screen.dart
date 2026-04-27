import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:pantheon/services/auth_service.dart';
import 'package:pantheon/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Por favor completa todos los campos');
      return;
    }
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();

    try {
      final success = await authService.login(
          _emailController.text, _passwordController.text);

      setState(() => _isLoading = false);

      if (success && mounted) {
        final user = authService.currentUser;
        debugPrint('LOGIN SUCCESS. User: ${user?.name}');
        debugPrint('Category: "${user?.category}"');
        debugPrint('Position: "${user?.position}"');
        debugPrint('Age: "${user?.age}"');

        // If critical profile fields are missing, go to profile questions
        if (user != null &&
            (user.category.isEmpty ||
                user.position.isEmpty ||
                user.age.isEmpty)) {
          debugPrint('Redirecting to Profile Questions (Incomplete Profile)');
          context.go('/profile-questions');
        } else {
          debugPrint('Redirecting to Home (Complete Profile)');
          context.go('/home');
        }
      }
    } on DioException catch (e) {
      setState(() => _isLoading = false);

      // Handle 403 - Account not confirmed
      if (e.response?.statusCode == 403) {
        final mensaje = e.response?.data['mensaje'] ?? '';
        if (mensaje.toLowerCase().contains('confirmada') ||
            mensaje.toLowerCase().contains('activa')) {
          // Account not confirmed - navigate to confirmation screen
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cuenta no confirmada'),
                content: const Text(
                  'Tu cuenta aún no ha sido confirmada. Te enviaremos un nuevo código de verificación.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop(); // Close dialog
                      context.go(
                          '/email-confirmation?email=${Uri.encodeComponent(_emailController.text)}');
                    },
                    child: Text(
                      'IR A CONFIRMACIÓN',
                      style: TextStyle(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return;
        }
      }

      // Other errors
      if (mounted) {
        _showError('Email o contraseña incorrectos');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showError('Error de conexión');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlueBackground,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Text(
                  'INICIO',
                  style: context.textStyles.displayMedium?.copyWith(
                    color: AppColors.neonGreen,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Icon(
                  Icons.sports_tennis,
                  size: 64,
                  color: AppColors.neonGreen,
                ),
              ),
              const SizedBox(height: 60),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle: TextStyle(color: AppColors.textGrey),
                  prefixIcon:
                      Icon(Icons.email_outlined, color: AppColors.neonGreen),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.textGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppColors.neonGreen, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Introduce tu contraseña',
                  labelStyle: TextStyle(color: AppColors.textGrey),
                  prefixIcon:
                      Icon(Icons.lock_outline, color: AppColors.neonGreen),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textGrey,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.textGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppColors.neonGreen, width: 2),
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'INICIAR SESIÓN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black, // Ensure dark text
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.sports_tennis,
                              color: Colors.black, // Ensure dark icon
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: AppColors.textGrey,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/register'),
                  child: Text(
                    '¿No tienes cuenta? Regístrate aquí',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: AppColors.neonGreen,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
