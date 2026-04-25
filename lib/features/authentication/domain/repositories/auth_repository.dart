import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../../data/datasources/discord_auth_data.dart';

/// Defines the contract for all authentication operations in Rythmify.
///
/// All methods return [Either]:
/// - [Left] wraps a [Failure] describing what went wrong.
/// - [Right] wraps the successful result.
abstract class AuthRepository {
  /// Signs in an existing user with email and password.
  ///
  /// Returns [Right] with a [UserEntity] on success.
  /// Returns [Left] with [InvalidCredentialsFailure] for wrong credentials,
  /// or [EmailNotVerifiedFailure] if the account is unverified.
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registers a new account with email and password.
  ///
  /// Returns [Right] with a [UserEntity] on success.
  /// Returns [Left] with [EmailAlreadyInUseFailure] if the email exists.
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required String gender,
    required String dateOfBirth,
  });

  /// Signs in using a Google account via Firebase OAuth.
  ///
  /// Returns [Right] with a [UserEntity] on success.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Completes registration for a Google OAuth user.
  ///
  /// Returns [Right] with a [UserEntity] on success.
  Future<Either<Failure, UserEntity>> signUpWithGoogle({
    required String idToken,
    required String gender,
    required String dateOfBirth,
  });

  /// Signs in using Apple ID.
  ///
  /// Returns [Right] with a [UserEntity] on success.
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Authenticates the user via GitHub OAuth.
  ///
  /// Opens the GitHub consent screen in the system browser, waits for the
  /// deep-link callback, then exchanges the code with the backend.
  ///
  /// Returns [Right] with [GitHubAuthData] on success.
  /// Returns [Left] with [GitHubAuthFailure] if the user cancels or the
  /// backend rejects the token.
  Future<Either<Failure, GitHubAuthData>> loginWithGitHub();

  /// Signs out the currently authenticated user and clears stored tokens.
  Future<Either<Failure, void>> signOut();

  /// Sends an email verification link to the current user.
  Future<Either<Failure, void>> sendVerificationEmail();

  /// Sends a password reset email to [email].
  Future<Either<Failure, void>> sendPasswordReset({required String email});
}
