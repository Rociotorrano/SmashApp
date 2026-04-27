import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:pantheon/models/user_model.dart';
import 'package:pantheon/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> init() async {
    final hasToken = await ApiService().hasToken();
    if (hasToken) {
      try {
        final response = await ApiService().get('/usuarios/yo');
        if (response.data['exito'] == true) {
          _currentUser = UserModel.fromProfileJson(response.data['datos']);
          notifyListeners();
        } else {
          await logout();
        }
      } catch (e) {
        debugPrint('Error initializing auth: $e');
        await logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService().post('/auth/iniciar-sesion', data: {
        'email': email,
        'password': password,
      });

      if (response.data['exito'] == true) {
        final datos = response.data['datos'];
        final tokens = datos['tokens'];
        final accessToken = tokens['accessToken'];
        final refreshToken = tokens['refreshToken'];

        await ApiService()
            .saveTokens(accessToken: accessToken, refreshToken: refreshToken);
        await init();

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return false;
    }
  }

  Future<String?> register(String email, String password, String name) async {
    try {
      final response = await ApiService().post('/auth/registrarse', data: {
        'email': email,
        'password': password,
        'nombre': name,
      });

      if (response.statusCode == 201 && response.data['exito'] == true) {
        return null; // Success
      }

      // Handle case: user created but email failed
      if (response.data['error']?['causa'] == 'email_no_enviado') {
        return null;
      }

      return response.data['mensaje'] ?? 'Error desconocido';
    } catch (e) {
      debugPrint('Error registering: $e');
      // Extract error message from ApiException if avail
      if (e is DioException && e.error is ApiException) {
        return (e.error as ApiException).message;
      }
      return 'Error de conexión: $e';
    }
  }

  Future<String?> confirmEmail(String email, String codigo) async {
    try {
      final response = await ApiService().post('/auth/confirmar-email', data: {
        'email': email,
        'codigo': codigo,
      });

      if (response.data['exito'] == true) {
        return null; // Success
      }
      return response.data['mensaje'] ?? 'Código inválido';
    } catch (e) {
      debugPrint('Error confirming email: $e');
      if (e is DioException && e.error is ApiException) {
        return (e.error as ApiException).message;
      }
      return 'Error de conexión: $e';
    }
  }

  Future<String?> resendCode(String email) async {
    try {
      final response = await ApiService().post('/auth/reenviar-codigo', data: {
        'email': email,
      });

      if (response.data['exito'] == true) {
        return null; // Success
      }
      return response.data['mensaje'] ?? 'Error al reenviar código';
    } catch (e) {
      debugPrint('Error resending code: $e');
      if (e is DioException && e.error is ApiException) {
        return (e.error as ApiException).message;
      }
      return 'Error de conexión: $e';
    }
  }

  Future<String?> solicitarRestablecimientoPassword(String email) async {
    try {
      final response = await ApiService()
          .post('/auth/password/solicitar-restablecimiento', data: {
        'email': email,
      });

      if (response.data['exito'] == true) {
        return null; // Success
      }
      return response.data['mensaje'] ?? 'Error al solicitar el código';
    } catch (e) {
      debugPrint('Error soliciting password reset: $e');
      if (e is DioException && e.error is ApiException) {
        return (e.error as ApiException).message;
      }
      return 'Error de conexión: $e';
    }
  }

  Future<String?> confirmarRestablecimientoPassword({
    required String email,
    required String codigo,
    required String nuevaPassword,
  }) async {
    try {
      final response = await ApiService()
          .post('/auth/password/confirmar-restablecimiento', data: {
        'email': email,
        'codigo': codigo,
        'nuevaPassword': nuevaPassword,
      });

      if (response.data['exito'] == true) {
        return null; // Success
      }
      return response.data['mensaje'] ?? 'Error al restablecer contraseña';
    } catch (e) {
      debugPrint('Error confirming password reset: $e');
      if (e is DioException && e.error is ApiException) {
        return (e.error as ApiException).message;
      }
      return 'Error de conexión: $e';
    }
  }

  Future<void> updateCurrentUser(UserModel user) async {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      const storage = FlutterSecureStorage();
      final refreshToken = await storage.read(key: 'refresh_token');
      await ApiService().post('/auth/cerrar-sesion', data: {
        'refreshToken': refreshToken,
      });
    } catch (e) {
      // Ignore errors on logout
    } finally {
      await ApiService().deleteTokens();
      _currentUser = null;
      notifyListeners();
    }
  }
}
