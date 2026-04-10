// coverage:ignore-file
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';
import '../../../../core/network/api_client.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      final user = data['user'];
      return UserModel.fromJson({
        'id': user['user_id'].toString(),
        'email': user['email'],
        'display_name': user['display_name'],
        'avatar_url': user['avatar_url'] ?? user['profile_picture'],
        'is_email_verified': user['is_verified'],
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
  /// `date_of_birth`, `captcha_token` and `platform`
  /// to create a new user account.
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
  /// [captchaToken] — optional CAPTCHA token for verification.
  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String gender,
    required String dateOfBirth,
    String? captchaToken,
  }) async {
    try {
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
        'avatar_url': data['avatar_url'] ?? data['profile_picture'] ?? '',
        'is_email_verified': false,
        'captcha_token': null,
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
  /// 5. Sends the ID token to `POST /auth/google`.
  /// 6. Saves the returned JWT and returns a [UserModel].
  ///
  /// Throws an [Exception] with the cancellation or error message if
  /// any step fails.
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // IMPORTANT: This MUST match the backend's GOOGLE_CLIENT_ID
      // Backend expects: 456932364376-4ga0v16rd7dhemov4navlepcne4u51n8.apps.googleusercontent.com
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId:
            '456932364376-4ga0v16rd7dhemov4navlepcne4u51n8.apps.googleusercontent.com',
      );

      // Sign out first to ensure account picker shows
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // For Firebase integration (optional - can remove if not needed)
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Send the Google OAuth ID token to backend
      // This is what the backend validates with google-auth-library
      final response = await client.dio.post(
        '/auth/google',
        data: {'id_token': googleAuth.idToken},
      );

      final data = response.data['data'];
      final token = data['access_token'] as String;
      await client.saveToken(token);

      final user = data['user'];
      return UserModel.fromJson({
        'id': user['user_id'],
        'email': user['email'],
        'display_name': user['display_name'],
        'avatar_url': user['avatar_url'] ?? user['profile_picture'],
        'is_email_verified': user['is_verified'] ?? true,
        'token': token,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
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
      final response = await client.dio.post(
        '/auth/apple',
        data: {'id_token': 'APPLE_ID_TOKEN_HERE'},
      );

      final responseData = response.data is List
          ? response.data[0]
          : response.data;

      final data = responseData['data'];
      final token = data['access_token'] as String;
      await client.saveToken(token);

      final user = data['user'];
      return UserModel.fromJson({
        'id': user['user_id'].toString(),
        'email': user['email'],
        'display_name': user['display_name'],
        'avatar_url': user['avatar_url'] ?? user['profile_picture'],
        'is_email_verified': true,
        'token': token,
      });
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
      await client.clearToken();
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
    final errorCode = e.response?.data?['error']?['code'] as String?;
    final errorMessage = e.response?.data?['error']?['message'] as String?;

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
