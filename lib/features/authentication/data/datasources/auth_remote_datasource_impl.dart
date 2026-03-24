import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';
import '../../../../core/network/api_client.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        'is_email_verified': user['is_verified'],
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
    required String gender,
    required String dateOfBirth,
  }) async {
    try {
      final response = await client.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'display_name': displayName,
          'gender': gender,
          'date_of_birth': dateOfBirth,
          'captcha_token': 'dev-bypass',
        },
      );

      final responseData = response.data is List
          ? response.data[0]
          : response.data;

      final data = responseData['data'];

      return UserModel.fromJson({
        'id': data['user_id'].toString(),
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
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final firebaseUser = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      final idToken = await firebaseUser.user!.getIdToken();

      final response = await client.dio.post(
        '/auth/google',
        data: {'id_token': idToken},
      );

      final data = response.data['data'];
      final token = data['access_token'] as String;
      await client.saveToken(token);

      final user = data['user'];
      return UserModel.fromJson({
        'id': user['user_id'],
        'email': user['email'],
        'display_name': user['display_name'],
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

  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await client.dio.post(
        '/auth/check-email',
        data: {'email': email},
      );

      return response.data['exists']; // true or false
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
      await client.dio.post('/auth/resend-verification');
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await client.dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

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
