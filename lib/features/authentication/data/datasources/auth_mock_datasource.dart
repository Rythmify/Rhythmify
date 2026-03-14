import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class AuthMockDatasource implements AuthRemoteDatasource {
  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate wrong password
    if (password != 'password123') {
      throw Exception('Invalid email or password.');
    }

    return const UserModel(
      id: 'mock-user-001',
      email: 'karim@rythmify.com',
      displayName: 'Karim',
      isEmailVerified: true,
      token: 'mock-jwt-token-xyz',
    );
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    return UserModel(
      id: 'mock-user-002',
      email: email,
      displayName: displayName,
      isEmailVerified: false,
      token: 'mock-jwt-token-abc',
    );
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));

    return const UserModel(
      id: 'mock-user-003',
      email: 'karim.google@gmail.com',
      displayName: 'Karim Google',
      isEmailVerified: true,
      token: 'mock-google-token-xyz',
    );
  }

  @override
  Future<UserModel> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 1));

    return const UserModel(
      id: 'mock-user-004',
      email: 'karim.apple@icloud.com',
      displayName: 'Karim Apple',
      isEmailVerified: true,
      token: 'mock-apple-token-xyz',
    );
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> sendVerificationEmail() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}