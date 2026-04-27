import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:pantheon/models/user_model.dart';
import 'package:pantheon/services/api_service.dart';

class UserService {
  static XFile? pendingPhoto;

  static Future<UserModel?> getMe() async {
    try {
      final response = await ApiService().get('/usuarios/yo');
      if (response.data['exito'] == true) {
        return UserModel.fromProfileJson(response.data['datos']);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  static Future<bool> updateProfile(UserModel user) async {
    try {
      // Map user model to camelCase body expected by backend
      // Backend expects: { nombre, genero?, rangoEdad?, experienciaPadel?, categoria?, posicionPreferida?, horarioDisponible?, localidad?, biografia? }
      final data = {
        'nombre': user.name,
        'genero': user.gender.isEmpty ? null : user.gender,
        'rangoEdad': user.age.isEmpty ? null : user.age,
        'experienciaPadel':
            user.yearsPlaying, // Always send as int (0 is valid)
        'categoria': user.category.isEmpty ? null : user.category,
        'posicionPreferida': user.position.isEmpty ? null : user.position,
        'horarioDisponible': user.schedule.isEmpty ? null : user.schedule,
        'localidad': user.locality.isEmpty ? null : user.locality,
        'biografia': (user.biography == null || user.biography!.isEmpty)
            ? null
            : user.biography,
      };

      final response =
          await ApiService().put('/usuarios/yo/perfil', data: data);
      return response.data['exito'] == true;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  static Future<List<UserModel>> searchUsers({
    String? locality,
    String? category,
    String? schedule,
    String? gender,
    String? ageRange,
    bool excludeConnected = true,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        if (locality != null) 'localidad': locality,
        if (category != null) 'categoria': category,
        if (schedule != null) 'horario_disponible': schedule,
        if (gender != null) 'genero': gender,
        if (ageRange != null) 'rango_edad': ageRange,
        'excluirConectados': excludeConnected.toString(),
        'page': page,
        'limit': limit,
      };

      final response = await ApiService()
          .get('/usuarios/buscar', queryParameters: queryParams);

      if (response.data['exito'] == true) {
        final List data = response.data['datos']['resultados'];
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  // Wrappers for Photos
  static Future<bool> uploadPhoto(String filePath,
      {bool isMain = false}) async {
    try {
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(filePath),
        'es_principal': isMain,
      });

      final response =
          await ApiService().post('/usuarios/fotos', data: formData);
      return response.data['exito'] == true;
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      return false;
    }
  }

  // Placeholder for getting user by specific ID if needed (or use search)
  static Future<UserModel?> getUserById(String id) async {
    // Backend doesn't have /usuarios/:id explicitly listed in "Endpoints reales",
    // but typical setups might. Or we use search by ID if supported.
    // For now, return null or implement if backend supports it.
    // Docs say: GET /usuarios/buscar (search).
    return null;
  }

  // Contacts
  // Contacts
  static Future<Map<String, dynamic>> requestContact(String userId) async {
    try {
      debugPrint('Solicitando contacto con: $userId');
      final response = await ApiService().post('/contactos/solicitar', data: {
        'destinatarioId': userId,
      });

      if (response.data['exito'] == true) {
        // Puede que el backend devuelva la conexión si es un match inmediato
        final connectionId =
            response.data['datos']?['conexion_id']?.toString() ??
                response.data['datos']?['id']?.toString();
        return {'success': true, 'connectionId': connectionId};
      }

      final mensaje = response.data['mensaje'] ?? 'Error desconocido';
      final mensajeLower = mensaje.toLowerCase();

      // Si ya existe la solicitud, intentamos extraer el ID si viene en el error/datos
      if (mensajeLower.contains('ya existe') ||
          mensajeLower.contains('pendiente')) {
        final connectionId =
            response.data['datos']?['conexion_id']?.toString() ??
                response.data['datos']?['id']?.toString();
        return {
          'success': true,
          'connectionId': connectionId,
          'alreadyExists': true
        };
      }

      return {'success': false, 'error': mensaje};
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      debugPrint('Detectado error en catch requestContact: $errorStr');

      if (errorStr.contains('ya existe') ||
          errorStr.contains('pendiente') ||
          errorStr.contains('already exists')) {
        // Intentar extraer de la respuesta del error si es un DioException
        String? connId;
        if (e is DioException && e.response?.data != null) {
          final data = e.response!.data;
          connId = data['datos']?['conexion_id']?.toString() ??
              data['datos']?['id']?.toString();
        }
        return {'success': true, 'connectionId': connId, 'alreadyExists': true};
      }

      if (e is DioException && e.error is ApiException) {
        return {'success': false, 'error': (e.error as ApiException).message};
      }
      return {'success': false, 'error': 'Error de conexión: $e'};
    }
  }
}
