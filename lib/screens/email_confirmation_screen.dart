import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pantheon/services/auth_service.dart';
import 'package:pantheon/theme.dart';

class EmailConfirmationScreen extends StatefulWidget {
  final String email;

  const EmailConfirmationScreen({super.key, required this.email});

  @override
  State<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmEmail() async {
    if (_codeController.text.length != 6) {
      _showError('El código debe tener 6 dígitos');
      return;
    }

    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();

    final error = await authService.confirmEmail(
      widget.email,
      _codeController.text,
    );

    setState(() => _isLoading = false);

    if (error == null && mounted) {
      // Success - show dialog and go to login
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('¡Email Confirmado!'),
          content: const Text(
            'Tu cuenta ha sido activada exitosamente. Ahora puedes iniciar sesión.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(); // Close dialog
                context.go('/login'); // Go to login
              },
              child: Text(
                'IR AL LOGIN',
                style: TextStyle(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (mounted) {
      _showError(error ?? 'Error al confirmar el código');
    }
  }

  Future<void> _handleResendCode() async {
    setState(() => _isResending = true);
    final authService = context.read<AuthService>();

    final error = await authService.resendCode(widget.email);

    setState(() => _isResending = false);

    if (error == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Código reenviado a tu correo'),
          backgroundColor: AppColors.neonGreen,
        ),
      );
    } else if (mounted) {
      _showError(error ?? 'Error al reenviar el código');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.neonGreen),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'CONFIRMAR EMAIL',
                style: context.textStyles.displayMedium?.copyWith(
                  color: AppColors.neonGreen,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.mark_email_read,
                size: 80,
                color: AppColors.neonGreen,
              ),
              const SizedBox(height: 32),
              Text(
                'Te hemos enviado un código de 6 dígitos a:',
                style: context.textStyles.bodyLarge?.copyWith(
                  color: AppColors.textGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: context.textStyles.titleMedium?.copyWith(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.neonGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'El código expira en 5 minutos',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Código de verificación',
                  hintText: '000000',
                  labelStyle: TextStyle(color: AppColors.textGrey),
                  prefixIcon: Icon(Icons.vpn_key, color: AppColors.neonGreen),
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
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: context.textStyles.headlineMedium?.copyWith(
                  letterSpacing: 8,
                  color: Colors.white,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleConfirmEmail,
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          'CONFIRMAR',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _isResending ? null : _handleResendCode,
                child: _isResending
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        '¿No recibiste el código? Reenviar',
                        style: context.textStyles.bodyMedium?.copyWith(
                          color: AppColors.textGrey,
                          decoration: TextDecoration.underline,
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
