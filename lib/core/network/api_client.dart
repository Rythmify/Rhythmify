import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class ApiClient {
  // Use your computer's IP for physical phone connection
  // Change this when we make it online

  static const String _baseUrl =
      'https://rythmify-backend-dev.livelypebble-6b7965ef.uaenorth.azurecontainerapps.io/api/v1';

  static const String _tokenKey = 'access_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio dio;
  late final CookieJar cookieJar;

  ApiClient() {
    // Initialize cookie jar (in-memory for now, will persist on first use)
    cookieJar = CookieJar();

    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15), // Increase timeout
        receiveTimeout: const Duration(seconds: 15),
        // Don't set Content-Type globally - let Dio handle it per request
        // (application/json for JSON, multipart/form-data for file uploads)
      ),
    );

    // Add cookie manager to handle refresh token cookies
    dio.interceptors.add(CookieManager(cookieJar));

    // --- ADDING VERBOSE NETWORK LOGS ---
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
    // ------------------------------------

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Debug: Print headers for every request
          print('🔵 API Request: ${options.method} ${options.path}');
          print('🔵 Headers: ${options.headers}');
          if (options.data is FormData) {
            print('🔵 Body: FormData (file upload)');
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final errorCode = error.response?.data?['error']?['code'];
            final requestPath = error.requestOptions.path;
            final isRefreshRequest = requestPath == '/auth/refresh';
            final hasRefreshCookie = await _hasRefreshCookie();

            // Handle both expired and invalid tokens with refresh attempt
            if (errorCode == 'AUTH_TOKEN_EXPIRED' ||
                errorCode == 'AUTH_TOKEN_INVALID') {
              if (isRefreshRequest || !hasRefreshCookie) {
                await clearToken();
                return handler.next(error);
              }
              print('🔴 Token error: $errorCode - attempting refresh');
              try {
                final newToken = await _refreshToken();
                print('🟢 Token refreshed successfully');
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                print('🔴 Token refresh failed: $e');
                await clearToken();
                // User needs to log in again
                return handler.next(error);
              }
            } else {
              print('🔴 401 error with code: $errorCode - clearing token');
              await clearToken();
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
    // Also clear all cookies (including refresh token)
    cookieJar.deleteAll();
    print('🔴 Cleared access token and all cookies');
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

  Future<bool> _hasRefreshCookie() async {
    final refreshUri = Uri.parse('${dio.options.baseUrl}/auth/refresh');
    final cookies = await cookieJar.loadForRequest(refreshUri);
    return cookies.isNotEmpty;
  }
}

final apiClient = ApiClient();
