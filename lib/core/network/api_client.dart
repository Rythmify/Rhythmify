import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared API client that manages authenticated HTTP requests and token refresh.
class ApiClient {
  // Use your computer's IP for physical phone connection
  // Change this when we make it online

  static const String _baseUrl =
      'https://rythmify-backend-dev.livelypebble-6b7965ef.uaenorth.azurecontainerapps.io/api/v1';
  static const String baseUrl = _baseUrl;

  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio dio;
  Future<String?>? _refreshFuture;

  /// Called when the session becomes invalid and the app should go to login.
  VoidCallback? onSessionExpired;

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
          final skipAuth = options.extra['skipAuth'] == true;
          final token = await getToken();
          if (!skipAuth && token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          final isRefreshRequest = request.path.contains('/auth/refresh');
          final alreadyRetried = request.extra['didRefreshRetry'] == true;

          if (error.response?.statusCode == 401 &&
              !isRefreshRequest &&
              !alreadyRetried) {
            try {
              final newToken = await _refreshAccessToken();
              if (newToken == null) {
                await clearTokens();
                onSessionExpired?.call();
                return handler.next(error);
              }

              request.headers['Authorization'] = 'Bearer $newToken';
              request.extra['didRefreshRetry'] = true;
              final response = await dio.fetch(request);
              return handler.resolve(response);
            } catch (_) {
              await clearTokens();
              onSessionExpired?.call();
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Persists a new access token.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Persists a new refresh token.
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Persists both access and refresh tokens.
  Future<void> saveAuthTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await saveToken(accessToken);
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      await saveRefreshToken(refreshToken);
    }
  }

  /// Returns the current access token if available.
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Returns the current refresh token if available.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Clears only the access token.
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Clears both access and refresh tokens.
  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Refreshes the access token and rotates refresh token when returned.
  Future<String?> refreshAccessToken() => _refreshAccessToken();

  /// Ensures only one refresh call is in-flight at a time.
  Future<String?> _refreshAccessToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture!;
    }
    _refreshFuture = _performRefresh();
    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  /// Calls `POST /auth/refresh` using the stored refresh token.
  Future<String?> _performRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      return null;
    }

    final response = await dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
      options: Options(extra: {'skipAuth': true}),
    );

    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final newToken = data['access_token'] as String?;
    if (newToken == null || newToken.isEmpty) {
      return null;
    }

    await saveToken(newToken);
    final rotatedRefreshToken = data['refresh_token'] as String?;
    if (rotatedRefreshToken != null && rotatedRefreshToken.isNotEmpty) {
      await saveRefreshToken(rotatedRefreshToken);
    }
    return newToken;
  }
}

final apiClient = ApiClient();
