import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case that signs out the currently authenticated user.
///
/// Delegates to [AuthRepository.signOut], which clears the stored JWT
/// token from secure storage.
class SignOutUseCase {
  /// The repository used to perform the sign-out operation.
  final AuthRepository repository;

  /// Creates a [SignOutUseCase] with the given [repository].
  SignOutUseCase(this.repository);

  /// Executes the sign-out operation.
  ///
  /// Returns [Right] with `void` on success, or [Left] with a
  /// [Failure] if the request fails.
  Future<Either<Failure, void>> call() {
    return repository.signOut();
  }
}
