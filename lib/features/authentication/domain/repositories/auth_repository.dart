import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Defines the contract for all authentication operations in Rythmify.
/// This abstract class sits in the domain layer and has no knowledge of
/// how data is fetched or stored. Concrete implementations live in the
/// data layer (e.g. [AuthRepositoryImpl]).
/// All methods return [Either] from the `dartz` package:
/// - [Left] wraps a [Failure] describing what went wrong.
/// - [Right] wraps the successful result.

abstract class AuthRepository {
  /// Signs in an existing user with their email address and password.
  /// Returns [Right] with a [UserEntity] on success.
  /// Returns [Left] with [InvalidCredentialsFailure] if the credentials
  /// are incorrect, or [EmailNotVerifiedFailure] if the account is
  /// unverified.
  ///
  /// [email] — the user's registered email address.
  /// [password] — the user's plain-text password.
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registers a new user account with email and password.
  /// Returns [Right] with a [UserEntity] on success.
  /// Returns [Left] with [EmailAlreadyInUseFailure] if the email is
  /// already registered.
  ///
  /// [email] — the new user's email address.
  /// [password] — the desired password (must meet strength requirements).
  /// [displayName] — the name shown publicly across the app.
  /// [gender] — the user's gender, sent as a lowercase string (e.g. `'male'`).
  /// [dateOfBirth] — formatted as `YYYY-MM-DD` per the API spec.
  
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
  /// Returns [Left] with an appropriate [Failure] if the sign-in
  /// is cancelled or fails.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Signs in using an Apple ID via Firebase OAuth.
  ///
  /// Returns [Right] with a [UserEntity] on success.
  /// Returns [Left] with an appropriate [Failure] if the sign-in
  /// is cancelled or fails.
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Signs out the currently authenticated user.
  ///
  /// Clears the stored JWT token from secure storage.
  /// Returns [Right] with `void` on success.
  /// Returns [Left] with a [Failure] if the sign-out request fails.
  Future<Either<Failure, void>> signOut();

  /// Sends an email verification link to the current user's email address.
  ///
  /// Returns [Right] with `void` on success.
  /// Returns [Left] with a [Failure] if the request fails.
  Future<Either<Failure, void>> sendVerificationEmail();

  /// Sends a password reset email to the given address.
  ///
  /// Returns [Right] with `void` if the email was dispatched.
  /// Returns [Left] with [InvalidCredentialsFailure] if no account
  /// exists for the given [email].
  ///
  /// [email] — the email address associated with the account to reset.
  
  Future<Either<Failure, void>> sendPasswordReset({required String email});
}