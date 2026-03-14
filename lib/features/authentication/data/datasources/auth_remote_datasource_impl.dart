import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';
import '../../../../core/network/api_client.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient client;

  AuthRemoteDatasourceImpl({required this.client});

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data['data'];
      final token = data['access_token'] as String;

      // Save token to secure storage
      await client.saveToken(token);

      return UserModel.fromJson({
        'id': data['user']['id'],
        'email': data['user']['email'],
        'display_name': data['user']['display_name'],
        'is_email_verified': data['user']['is_email_verified'],
        'token': token,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await client.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'display_name': displayName,
        },
      );

      final data = response.data['data'];

      // No token yet — user must verify email first
      return UserModel.fromJson({
        'id': data['id'],
        'email': data['email'],
        'display_name': data['display_name'],
        'is_email_verified': false,
        'token': null,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Step 1 — get Google id_token from google_sign_in package
      // This part stays the same as before
      // Step 2 — send it to our backend
      final response = await client.dio.post(
        '/auth/google',
        data: {
          'id_token': 'GOOGLE_ID_TOKEN_HERE',
        },
      );

      final data = response.data['data'];
      final token = data['access_token'] as String;
      await client.saveToken(token);

      return UserModel.fromJson({
        'id': data['user']['id'],
        'email': data['user']['email'],
        'display_name': data['user']['display_name'],
        'is_email_verified': true,
        'token': token,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      final response = await client.dio.post(
        '/auth/apple',
        data: {
          'id_token': 'APPLE_ID_TOKEN_HERE',
        },
      );

      final data = response.data['data'];
      final token = data['access_token'] as String;
      await client.saveToken(token);

      return UserModel.fromJson({
        'id': data['user']['id'],
        'email': data['user']['email'],
        'display_name': data['user']['display_name'],
        'is_email_verified': true,
        'token': token,
      });
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

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

  @override
  Future<void> sendVerificationEmail() async {
    try {
      // Gets current user email from token
      await client.dio.post('/auth/resend-verification');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await client.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  // ── Error handler ─────────────────────────────────
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
      default:
        throw Exception(errorMessage ?? 'Unknown error occurred');
    }
  }
}