import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  final String message;
  final bool success;
  final dynamic data;

  ApiException({
    required this.message,
    this.success = false,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Use http://10.0.2.2:3000 for Android Emulator, http://localhost:3000 for iOS/Web
  // Ideally this should be in an environment config
  static const String _baseUrl = 'http://11.11.15.20:3001';

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        return status! < 600; // Capture all status codes to debug 500 errors
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] =
              'Bearer $token'; // Changed to standard 'Authorization'
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Standardize response handling
        // Check standard envelope
        if (response.data is Map<String, dynamic>) {
          final data = response.data;
          if (data.containsKey('exito') && data['exito'] == false) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: ApiException(
                  message: data['mensaje'] ?? 'Unknown error',
                  success: false,
                  data: data,
                ),
                response: response,
                type: DioExceptionType.badResponse,
              ),
            );
          }
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        // Handle Token Refresh on 401
        if (e.response?.statusCode == 401) {
          final refreshToken = await _storage.read(key: 'refresh_token');
          if (refreshToken != null) {
            try {
              // Clone dio to avoid circular interceptors or use a fresh instance
              final tokenDio = Dio(BaseOptions(baseUrl: _baseUrl));
              final refreshResponse = await tokenDio.post(
                  '/auth/refrescar-token',
                  data: {'refreshToken': refreshToken});

              if (refreshResponse.data['exito'] == true) {
                final newAccess = refreshResponse.data['datos']['accessToken'];
                final newRefresh = refreshResponse.data['datos'][
                    'refreshToken']; // Optionally update refresh token if rotated

                await _storage.write(key: 'access_token', value: newAccess);
                if (newRefresh != null) {
                  await _storage.write(key: 'refresh_token', value: newRefresh);
                }

                // Retry original request
                final opts = e.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccess';
                final clonedRequest = await _dio.fetch(opts);
                return handler.resolve(clonedRequest);
              }
            } catch (refreshError) {
              // Refresh failed, clear tokens
              await deleteTokens();
            }
          }
        }

        debugPrint('API Error: ${e.message} ${e.response?.data}');
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return _dio.delete(path, data: data);
  }

  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}
