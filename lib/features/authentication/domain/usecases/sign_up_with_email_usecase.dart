import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case that registers a new user account with email and password.
///
/// Delegates to [AuthRepository.signUpWithEmail] and propagates the
/// [Either] result directly to the caller (presentation layer).
class SignUpWithEmailUseCase {
  /// The repository used to perform the registration operation.
  final AuthRepository repository;

  /// Creates a [SignUpWithEmailUseCase] with the given [repository].
  SignUpWithEmailUseCase(this.repository);

  /// Executes the registration operation.
  ///
  /// Returns [Right] with a [UserEntity] on success, or [Left] with a
  /// [Failure] (e.g. [EmailAlreadyInUseFailure]) on error.
  ///
  /// [email] — the new user's email address.
  /// [password] — the desired password.
  /// [displayName] — the name shown publicly across the app.
  /// [gender] — lowercase gender string (e.g. `'male'` or `'female'`).
  /// [dateOfBirth] — formatted as `YYYY-MM-DD`.
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String displayName,
    required String gender,
    required String dateOfBirth,
  }) {
    return repository.signUpWithEmail(
      email: email,
      password: password,
      displayName: displayName,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
  }
}
