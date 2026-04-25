import '../models/user_model.dart';

/// Remote datasource contract for authentication network operations.
abstract class AuthRemoteDatasource {
  /// Signs in with email and password.
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registers a new account with email and password.
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String gender,
    required String dateOfBirth,
  });

  /// Signs in using a Google ID token.
  Future<UserModel> signInWithGoogle();

  /// Completes Google sign-up with profile data.
  Future<UserModel> signUpWithGoogle({
    required String idToken,
    required String gender,
    required String dateOfBirth,
  });

  /// Opens the GitHub OAuth browser flow and exchanges the resulting
  /// code with the Rythmify backend.
  ///
  /// Returns the raw `data` map from the backend response on success.
  /// Throws a [String] error message on failure.
  Future<Map<String, dynamic>> loginWithGitHub();

  /// Signs out the current user and clears stored tokens.
  Future<void> signOut();

  /// Sends an email verification link.
  Future<void> sendVerificationEmail();

  /// Sends a password reset email.
  Future<void> sendPasswordReset({required String email});
}
