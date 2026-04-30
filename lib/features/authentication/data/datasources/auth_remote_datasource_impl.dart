// coverage:ignore-file
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';
import '../../../../core/network/api_client.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

/// Real HTTP implementation of [AuthRemoteDatasource].
///
/// Makes all network requests via the [ApiClient] Dio instance.
/// Communicates with the custom Node.js REST API at
/// `{baseUrl}/auth/*`.
///
/// All methods throw typed [Exception]s on failure (not [Either]).
/// The repository implementation ([AuthRepositoryImpl]) catches these
/// and maps them to the appropriate [Failure] subclass.
///
/// **Note**: [checkEmailExists] is present here but is NOT declared
/// on the [AuthRemoteDatasource] interface. It is a supplementary method
/// added directly to this implementation. Callers must use the concrete
/// type to access it.
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  /// The API client used to make authenticated HTTP requests.
  final ApiClient client;

  /// Creates an [AuthRemoteDatasourceImpl] with the given [client].
  AuthRemoteDatasourceImpl({required this.client});

  /// Signs in an existing user via `POST /auth/login`.
  ///
  /// Sends `identifier` (email) and `password` in the request body.
  /// On success, saves the returned JWT token via [ApiClient.saveToken]
  /// and returns a [UserModel].
  ///
  /// Throws typed [Exception]s via [_handleDioError] on failure:
  /// - `AUTH_INVALID_CREDENTIALS` — wrong email or password.
  /// - `AUTH_EMAIL_NOT_VERIFIED` — account not yet verified.
  ///
  /// [email] — the user's registered email address.
  /// [password] — the user's plain-text password.
  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.dio.post(
        '/auth/login',
        data: {'identifier': email, 'password': password},
      );

      final responseData = response.data is List
          ? response.data[0]
          : response.data;

      final data = responseData['data'];
      final token = data['access_token'] as String;
      await client.saveToken(token);

      /// refresh token is captured automatically by ApiClient._onResponse
      /// from the Set-Cookie header — no manual handling needed here;

      final user = data['user'];
      return UserModel.fromJson({
        ...user,
        'id': user['id']?.toString() ?? user['user_id']?.toString(),
        'is_email_verified':
            user['is_verified'] ?? user['is_email_verified'] ?? true,
        'avatar_url': user['profile_picture'] ?? user['avatar_url'],
        'token': token,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Registers a new user account via `POST /auth/register`.
  ///
  /// Sends `email`, `password`, `display_name`, `gender`,
  /// and `date_of_birth` to create a new user account.
  ///
  /// Parses `user_id` (not `id`) from the response per the API spec.
  /// Returns a [UserModel] with `token: null` (token is only issued
  /// after email verification + login).
  ///
  /// Throws typed [Exception]s on failure, including:
  /// - `AUTH_EMAIL_ALREADY_EXISTS` — email already registered.
  /// - `VALIDATION_FAILED` — request body failed server-side validation.
  ///
  /// [email] — the new user's email address.
  /// [password] — the desired password.
  /// [displayName] — the public display name.
  /// [gender] — lowercase gender string (e.g. `'male'`).
  /// [dateOfBirth] — formatted as `YYYY-MM-DD`.
  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String gender,
    required String dateOfBirth,
  }) async {
    try {
      /// Request body for [POST /auth/register].
      ///
      /// Sends `captcha_token` as `null` to bypass CAPTCHA in development.
      /// `platform` is included as `'mobile'` to identify the client type.
      final requestData = {
        'email': email,
        'password': password,
        'display_name': displayName,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'captcha_token': null,
        'platform': 'mobile',
      };

      final response = await client.dio.post(
        '/auth/register',
        data: requestData,
      );

      final responseData = response.data is List
          ? response.data[0]
          : response.data;

      final data = responseData['data'];

      return UserModel.fromJson({
        'id': data['user_id'].toString(),
        'email': data['email'],
        'display_name': data['display_name'],
        'avatar_url': data['avatar_url'] ?? '',
        'is_email_verified': false,
        'token': null,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Signs in using Google OAuth via Firebase + `POST /auth/google`.
  ///
  /// Flow:
  /// 1. Launches Google sign-in via [GoogleSignIn].
  /// 2. Obtains Firebase credential from [GoogleSignInAuthentication].
  /// 3. Signs into Firebase with the credential.
  /// 4. Gets the Firebase ID token.
  /// 5. Sends the ID token to `POST /auth/google` with `platform: 'mobile'`.
  /// 6. Saves the returned JWT and returns a [UserModel].
  ///
  /// **Error handling:**
  /// - On [PlatformException]: Handles user cancellation gracefully (returns
  ///   a non-throwing exception rather than crashing).
  /// - On [FirebaseAuthException]: Maps to a descriptive exception.
  /// - If `id_token` is null: Throws with a clear message instead of crashing.
  /// - On DioException: Delegates to [_handleDioError].
  ///
  /// Throws an [Exception] with descriptive error messages on any failure.
  @override
  Future<UserModel> signInWithGoogle() async {
    if (Platform.isWindows) {
      throw Exception(
        'Google Sign-In not supported on Windows. Use the browser OAuth flow from the sign-in page.',
      );
    }

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '456932364376-4ga0v16rd7dhemov4navlepcne4u51n8.apps.googleusercontent.com',
      );

      // Sign out first to ensure account picker shows
      await googleSignIn.signOut();

      late GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.signIn();
      } on PlatformException catch (e) {
        // User cancelled or platform error (e.g., permissions denied)
        // Return gracefully without rethrowing
        debugPrint('Google sign in cancelled or platform error: ${e.message}');
        throw Exception(e.message ?? 'Google sign in cancelled');
      }

      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Failed to get Google ID token. Device may not support Google Sign-In.',
        );
      }

      // For Firebase integration (optional - can remove if not needed)
      try {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        debugPrint('Firebase auth exception: $e');
        throw Exception('Firebase authentication failed: ${e.message}');
      }

      // Send the Google OAuth ID token to backend
      // This is what the backend validates with google-auth-library
      final response = await client.dio.post(
        '/auth/google',
        data: {'id_token': idToken, 'platform': 'mobile'},
      );

      final data = response.data['data'];
      final token = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String?;
      await client.saveAuthTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );

      final user = data['user'];
      return UserModel.fromJson({
        ...user,
        'id': user['id']?.toString() ?? user['user_id']?.toString(),
        'is_email_verified':
            user['is_verified'] ?? user['is_email_verified'] ?? true,
        'token': token,
      });
    } on DioException catch (e, stackTrace) {
      debugPrint('Google sign in backend exception: $e');
      debugPrintStack(stackTrace: stackTrace);
      _handleDioError(e);
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('Google sign in exception: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Completes registration for a user who signed in via Google OAuth.
  ///
  /// Called after the user authenticates with Google and fills in the
  /// registration form (gender, date of birth). Sends the Google ID token
  /// along with profile data to `POST /auth/google` to complete account setup.
  ///
  /// The backend responds with:
  /// - `is_new_user: true` — Account created; client should call `/users/me/onboarding`
  /// - `is_new_user: false` — Account already existed; skip onboarding, go to home
  ///
  /// Throws [DioException] on network failure.
  /// Throws generic [Exception] on credential problems.
  ///
  /// [idToken] — the Google ID token from [GoogleSignInAuthentication.idToken].
  /// [gender] — lowercase gender string (e.g. `'male'`, `'female'`).
  /// [dateOfBirth] — date in `YYYY-MM-DD` format.
  @override
  Future<UserModel> signUpWithGoogle({
    required String idToken,
    required String gender,
    required String dateOfBirth,
  }) async {
    try {
      final response = await client.dio.post(
        '/auth/google',
        data: {
          'id_token': idToken,
          'gender': gender,
          'date_of_birth': dateOfBirth,
          'platform': 'mobile',
        },
      );

      final data = response.data['data'];
      final token = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String?;
      await client.saveAuthTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );

      final user = data['user'];
      return UserModel.fromJson({
        ...user,
        'id': user['id']?.toString() ?? user['user_id']?.toString(),
        'is_email_verified':
            user['is_verified'] ?? user['is_email_verified'] ?? true,
        'avatar_url': user['profile_picture'] ?? user['avatar_url'],
        'token': token,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      debugPrint('Google signup exception: $e');
      rethrow;
    }
  }

  /// Checks whether an email address is already registered.
  ///
  /// Calls `POST /auth/check-email` with the given [email].
  /// Returns `true` if the email is taken, `false` otherwise.
  ///
  /// **Note**: This method is NOT declared on the [AuthRemoteDatasource]
  /// interface — it exists only on this concrete implementation.
  /// Callers must use [AuthRemoteDatasourceImpl] directly to call it.
  ///
  /// [email] — the email address to check.
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await client.dio.post(
        '/auth/check-email',
        data: {'email': email},
      );
      return response.data['exists'] as bool;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Signs in using Apple ID via `POST /auth/apple`.
  ///
  /// Currently sends a hardcoded placeholder `id_token`. Wire up
  /// real Apple Sign-In before production.
  ///
  /// Saves the returned JWT and returns a [UserModel].
  @override
  Future<UserModel> signInWithApple() async {
    try {
      // Placeholder implementation — real Apple Sign-In flow should be wired up
      final response = await client.dio.post(
        '/auth/apple',
        data: {'id_token': 'placeholder-apple-token'},
      );

      final data = response.data['data'];
      final token = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String?;
      await client.saveAuthTokens(
        accessToken: token,
        refreshToken: refreshToken,
      );

      final user = data['user'];
      return UserModel.fromJson({
        ...user,
        'id': user['id']?.toString() ?? user['user_id']?.toString(),
        'is_email_verified':
            user['is_verified'] ?? user['is_email_verified'] ?? true,
        'token': token,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Opens the GitHub OAuth consent screen via the system browser,
  /// waits for the deep-link callback (`rythmify://oauth`), then
  /// exchanges the authorization code with the Rythmify backend.
  ///
  /// Flow:
  /// 1. `GET /auth/github/url` → backend returns the GitHub auth URL.
  /// 2. [FlutterWebAuth2.authenticate] opens the browser and blocks
  ///    until `rythmify://oauth?code=...&state=...` fires.
  /// 3. Extracts `code` and `state` from the callback URI.
  /// 4. `POST /auth/github/callback` exchanges the code for tokens.
  /// 5. Saves the access token via [client.saveAuthTokens] and returns
  ///    the raw `data` map for [AuthRepositoryImpl] to parse.
  ///
  /// Throws [Exception('GITHUB_CANCELLED')] if the user closes the browser.
  /// Throws [Exception] via [_handleDioError] on any backend error.
  @override
  Future<Map<String, dynamic>> loginWithGitHub() async {
    try {
      // 1. Build the full authorization URL directly — no need to call
      //    the backend first since GET /auth/oauth/github is itself a redirect.
      final baseUrl = client.dio.options.baseUrl;
      final authUrl = '$baseUrl/auth/oauth/github';

      // 2. Open browser — blocks until rythmify://oauth?code=...&state=... fires
      late String result;
      try {
        result = await FlutterWebAuth2.authenticate(
          url: authUrl,
          callbackUrlScheme: 'rythmify',
        );
      } catch (_) {
        throw Exception('GITHUB_CANCELLED');
      }

      // 3. Extract code and state from the callback URI
      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];
      if (code == null) throw Exception('GITHUB_CANCELLED');
      final state = uri.queryParameters['state'];

      // 4. Exchange code — backend expects GET with query params
      final response = await client.dio.get(
        '/auth/oauth/github/callback',
        queryParameters: {'code': code, 'state': ?state},
      );

      // 5. Persist tokens
      final data = response.data['data'] as Map<String, dynamic>;
      final accessToken = data['access_token'] as String;
      final refreshToken = data['refresh_token'] as String?;
      await client.saveAuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      return data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Signs out the current user via `POST /auth/logout`.
  ///
  /// Also clears the stored JWT via [ApiClient.clearToken].
  @override
  Future<void> signOut() async {
    try {
      await client.dio.post('/auth/logout');
      await client.clearTokens();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Sends an email verification link via `POST /auth/resend-verification`.
  @override
  Future<void> sendVerificationEmail() async {
    try {
      await client.dio.post('/auth/resend-verification');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Sends a password reset email via `POST /auth/forgot-password`.
  ///
  /// [email] — the email address of the account to reset.
  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await client.dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  /// Maps a [DioException] to a typed [Exception] with a known error code.
  ///
  /// Reads `response.data['error']['code']` and
  /// `response.data['error']['message']` from the backend error response.
  /// Falls back to the message field or `'Unknown error occurred'` when
  /// the code is not in the known list.
  ///
  /// Known codes mapped:
  /// - `AUTH_INVALID_CREDENTIALS`
  /// - `AUTH_EMAIL_NOT_VERIFIED`
  /// - `AUTH_EMAIL_ALREADY_EXISTS`
  /// - `AUTH_ACCOUNT_SUSPENDED`
  /// - `AUTH_REFRESH_TOKEN_INVALID`
  /// - `RATE_LIMIT_EXCEEDED`
  /// - `VALIDATION_FAILED`
  void _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final errorCode = e.response?.data?['error']?['code'] as String?;
    final errorMessage = e.response?.data?['error']?['message'] as String?;
    final topLevelError = e.response?.data?['error'];
    final topLevelMessage = e.response?.data?['message'] as String?;
    final combinedMessage = [
      errorCode,
      errorMessage,
      topLevelError?.toString(),
      topLevelMessage,
    ].whereType<String>().join(' ').toLowerCase();

    if (statusCode == 409 ||
        errorCode == 'EMAIL_ALREADY_EXISTS' ||
        errorCode == 'AUTH_EMAIL_ALREADY_EXISTS' ||
        (statusCode == 400 && combinedMessage.contains('already exists')) ||
        combinedMessage.contains('email_already_exists') ||
        combinedMessage.contains('already exists')) {
      throw Exception('EMAIL_ALREADY_EXISTS');
    }

    switch (errorCode) {
      case 'AUTH_INVALID_CREDENTIALS':
        throw Exception('AUTH_INVALID_CREDENTIALS');
      case 'AUTH_EMAIL_NOT_VERIFIED':
        throw Exception('AUTH_EMAIL_NOT_VERIFIED');
      case 'AUTH_EMAIL_ALREADY_EXISTS':
        throw Exception('AUTH_EMAIL_ALREADY_EXISTS');
      case 'AUTH_ACCOUNT_SUSPENDED':
        throw Exception('AUTH_ACCOUNT_SUSPENDED');
      case 'AUTH_REFRESH_TOKEN_INVALID':
        throw Exception('AUTH_REFRESH_TOKEN_INVALID');
      case 'RATE_LIMIT_EXCEEDED':
        throw Exception('RATE_LIMIT_EXCEEDED');
      case 'VALIDATION_FAILED':
        throw Exception(errorMessage ?? 'VALIDATION_FAILED');
      default:
        throw Exception(errorMessage ?? 'Unknown error occurred');
    }
  }
}
