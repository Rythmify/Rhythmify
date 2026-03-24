import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Use your computer's IP for physical phone connection
  // Change this when we make it online
  static const String _baseUrl = 'http://192.168.100.10:8080/api/v1';   ///change this line to match your ip address

  static const String _tokenKey = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15), // Increase timeout
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // --- ADDING VERBOSE NETWORK LOGS ---
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ));
    }
    // ------------------------------------

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final errorCode = error.response?.data['error']['code'];
            if (errorCode == 'AUTH_TOKEN_EXPIRED') {
              try {
                final newToken = await _refreshToken();
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                await clearToken();
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<String> _refreshToken() async {
    final response = await dio.post(
      '/auth/refresh',
      options: Options(extra: {'skipAuth': true}),
    );
    final newToken = response.data['data']['access_token'] as String;
    await saveToken(newToken);
    return newToken;
  }
}

final apiClient = ApiClient();
