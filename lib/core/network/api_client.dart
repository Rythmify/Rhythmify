import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String _baseUrl = 'http://localhost:8080/api/v1';
  static const String _tokenKey = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Interceptor — attaches token + handles refresh automatically
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
          // If token expired — silently refresh and retry
          if (error.response?.statusCode == 401) {
            final errorCode = error.response?.data['error']['code'];
            if (errorCode == 'AUTH_TOKEN_EXPIRED') {
              try {
                final newToken = await _refreshToken();
                // Retry original request with new token
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

  // ── Token helpers ─────────────────────────────────
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // ── Silent token refresh ──────────────────────────
  Future<String> _refreshToken() async {
    // Refresh token is sent automatically via HTTP-only cookie
    final response = await dio.post(
      '/auth/refresh',
      options: Options(extra: {'skipAuth': true}),
    );
    final newToken = response.data['data']['access_token'] as String;
    await saveToken(newToken);
    return newToken;
  }
}

// Single instance shared across the app
final apiClient = ApiClient();