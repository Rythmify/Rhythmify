import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared API client that manages authenticated HTTP requests and token refresh.
///
/// Token strategy:
/// - Access token (JWT, 15 min TTL) — stored in [FlutterSecureStorage],
///   injected via the `Authorization: Bearer` header on every request.
/// - Refresh token (7 day TTL) — the backend sets it as an **HttpOnly cookie**
///   on login/register. On mobile we cannot rely on the browser cookie jar,
///   so we read the `Set-Cookie` response header after login and persist the
///   value ourselves in [FlutterSecureStorage].  We then replay it as a
///   `Cookie` request header when calling `POST /auth/refresh`.
///
/// Refresh flow (interceptor):
/// 1. Any `401` that is NOT the refresh endpoint itself triggers a silent
///    token refresh via [_refreshAccessToken].
/// 2. [_refreshFuture] ensures only one in-flight refresh exists at a time
///    (queued requests all wait for the same [Future]).
/// 3. After a successful refresh the original request is retried once with
///    the new access token.
/// 4. If the refresh fails (expired / invalid refresh token) all tokens are
///    cleared and [onSessionExpired] is invoked so the app navigates to login.
class ApiClient {
  static const String _baseUrl =
      'https://rythmify.duckdns.org/api/v1';
  static const String baseUrl = _baseUrl;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late final Dio dio;

  /// Guards against concurrent refresh calls — all callers share one [Future].
  Future<String?>? _refreshFuture;

  /// Called when the session becomes permanently invalid.
  /// The app should navigate to the login screen.
  VoidCallback? onSessionExpired;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: null,
        headers: {},
      ),
    );

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

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  // ─── interceptor callbacks ───────────────────────────────────────────────

  /// Injects the stored access token into every request unless
  /// `options.extra['skipAuth'] == true`.
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['X-Country-Code'] = 'EG';

    final skipAuth = options.extra['skipAuth'] == true;
    if (!skipAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  /// Captures `Set-Cookie` from login / register / refresh responses and
  /// persists the `refresh_token` cookie value so we can replay it later.
  ///
  /// The backend sets `refresh_token=<value>; HttpOnly; ...` — we parse out
  /// just the value and store it in secure storage.
  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      for (final cookie in setCookie) {
        if (cookie.startsWith('refresh_token=')) {
          // Extract just the token value (everything before the first ';')
          final value = cookie.split(';').first.split('=').skip(1).join('=');
          if (value.isNotEmpty) {
            await saveRefreshToken(value);
            debugPrint('[ApiClient] refresh_token captured from Set-Cookie');
          }
          break;
        }
      }
    }
    handler.next(response);
  }

  /// Silently refreshes the access token on `401` and retries the request.
  ///
  /// Guards:
  /// - Does NOT retry the refresh endpoint itself (avoids infinite loops).
  /// - Does NOT retry a request that was already retried once.
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;
    final isRefreshRequest = request.path.contains('/auth/refresh');
    final alreadyRetried = request.extra['didRefreshRetry'] == true;

    if (error.response?.statusCode == 401 &&
        !isRefreshRequest &&
        !alreadyRetried) {
      try {
        final newToken = await _refreshAccessToken();
        if (newToken == null) {
          await _expireSession();
          return handler.next(error);
        }

        // Retry the original request with the new token.
        request.headers['Authorization'] = 'Bearer $newToken';
        request.extra['didRefreshRetry'] = true;
        final response = await dio.fetch(request);
        return handler.resolve(response);
      } catch (_) {
        await _expireSession();
        return handler.next(error);
      }
    }

    handler.next(error);
  }

  // ─── token refresh ────────────────────────────────────────────────────────

  /// Public entry-point for manual refresh (used in [AuthNotifier.checkAuthStatus]).
  Future<String?> refreshAccessToken() => _refreshAccessToken();

  /// Ensures only one refresh call is in-flight at a time.
  ///
  /// Concurrent callers all await the same [Future] and receive the same token.
  Future<String?> _refreshAccessToken() {
    _refreshFuture ??= _performRefresh().whenComplete(() {
      _refreshFuture = null;
    });
    return _refreshFuture!;
  }

  /// Calls `POST /auth/refresh` with the stored refresh token as a `Cookie`
  /// header (mirrors the HttpOnly cookie the browser would send automatically).
  ///
  /// On success, persists the new access token and any rotated refresh token
  /// returned in either the response body or a new `Set-Cookie` header.
  ///
  /// Returns `null` when:
  /// - No refresh token is stored.
  /// - The backend returns an empty / missing `access_token`.
  Future<String?> _performRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      debugPrint('[ApiClient] No refresh token available — cannot refresh.');
      return null;
    }

    try {
      final response = await dio.post(
        '/auth/refresh',
        options: Options(
          extra: {'skipAuth': true}, // Don't inject the (expired) access token
          headers: {
            // Replay the refresh token as a cookie so the backend's
            // cookie-parser picks it up just like a browser would.
            'Cookie': 'refresh_token=$refreshToken',
          },
        ),
      );

      final data = (response.data['data'] as Map<String, dynamic>?) ?? {};
      final newAccessToken = data['access_token'] as String?;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        debugPrint('[ApiClient] Refresh response missing access_token.');
        return null;
      }

      await saveToken(newAccessToken);
      debugPrint('[ApiClient] Access token refreshed successfully.');

      // Handle rotated refresh token in body (some backends do this).
      final rotatedRefresh = data['refresh_token'] as String?;
      if (rotatedRefresh != null && rotatedRefresh.isNotEmpty) {
        await saveRefreshToken(rotatedRefresh);
        debugPrint('[ApiClient] Refresh token rotated (from body).');
      }
      // Note: rotation via Set-Cookie is handled by [_onResponse].

      return newAccessToken;
    } on DioException catch (e) {
      debugPrint(
        '[ApiClient] Refresh request failed: ${e.response?.statusCode}',
      );
      return null;
    }
  }

  /// Clears all tokens and notifies the app the session has expired.
  Future<void> _expireSession() async {
    await clearTokens();
    onSessionExpired?.call();
  }

  // ─── storage helpers ─────────────────────────────────────────────────────

  /// Persists [token] as the current access token.
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      debugPrint('[ApiClient] Failed to save token: $e');
    }
  }

  /// Persists [token] as the current refresh token.
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      debugPrint('[ApiClient] Failed to save refresh token: $e');
    }
  }

  /// Persists both tokens in parallel.
  Future<void> saveAuthTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await saveToken(accessToken);
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      await saveRefreshToken(refreshToken);
    }
  }

  /// Returns the stored access token, or `null` if none exists.
  ///
  /// Handles decryption failures (e.g. [BadPaddingException]) by clearing
  /// storage and returning null, forcing a fresh login.
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      debugPrint('[ApiClient] getToken decryption error: $e');
      await clearTokens(); // Wiping corrupted storage
      return null;
    }
  }

  /// Returns the stored refresh token, or `null` if none exists.
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('[ApiClient] getRefreshToken decryption error: $e');
      await clearTokens();
      return null;
    }
  }

  /// Deletes only the access token (keeps the refresh token).
  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _accessTokenKey);
    } catch (e) {
      debugPrint('[ApiClient] clearToken error: $e');
    }
  }

  /// Deletes both the access token and the refresh token.
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      debugPrint('[ApiClient] clearTokens error: $e');
    }
  }
}

final apiClient = ApiClient();
