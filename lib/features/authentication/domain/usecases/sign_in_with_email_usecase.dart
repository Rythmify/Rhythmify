import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
/// Use case that signs in an existing user with their email and password.
///
/// Delegates to [AuthRepository.signInWithEmail] and propagates the
/// [Either] result directly to the caller (presentation layer).

class SignInWithEmailUseCase {
  /// The repository used to perform the sign-in operation.
  final AuthRepository repository;
 
  /// Creates a [SignInWithEmailUseCase] with the given [repository].
  SignInWithEmailUseCase(this.repository);
 
  /// Executes the sign-in operation.
  ///
  /// Returns [Right] with a [UserEntity] on success, or [Left] with a
  /// [Failure] (e.g. [InvalidCredentialsFailure]) on error.
  ///
  /// [email] — the user's registered email address.
  /// [password] — the user's plain-text password.
  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    return repository.signInWithEmail(email: email, password: password);
  }
}
 