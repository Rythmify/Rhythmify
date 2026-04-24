import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Apple ID.
///
/// Orchestrates the Apple Sign-In flow via [AuthRepository.signInWithApple].
/// Returns [Either] to handle both success and failure cases.
class SignInWithAppleUseCase {
  /// The [AuthRepository] providing sign-in functionality.
  final AuthRepository repository;

  /// Creates a [SignInWithAppleUseCase] with the given [repository].
  SignInWithAppleUseCase(this.repository);

  /// Executes the Apple sign-in use case.
  ///
  /// Returns [Right] with a [UserEntity] on success.
  /// Returns [Left] with a [Failure] on error.
  Future<Either<Failure, UserEntity>> call() async {
    return repository.signInWithApple();
  }
}
