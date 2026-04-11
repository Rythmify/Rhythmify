import '../models/user_model.dart';

/// Remote datasource contract for authentication network operations.
abstract class AuthRemoteDatasource {
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String gender,
    required String dateOfBirth,
  });

  Future<UserModel> signInWithGoogle();

  Future<UserModel> signInWithApple();

  Future<void> signOut();
  Future<void> sendVerificationEmail();

  Future<void> sendPasswordReset({required String email});
}
