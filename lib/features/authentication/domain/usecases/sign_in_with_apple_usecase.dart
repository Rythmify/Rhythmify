import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case that signs in a user using their Apple ID via Firebase OAuth.
/// Delegates to [AuthRepository.signInWithApple].
class SignInWithAppleUseCase {
  /// The repository used to perform Apple sign-in.
  final AuthRepository repository;
 
  /// Creates a [SignInWithAppleUseCase] with the given [repository].
  SignInWithAppleUseCase(this.repository);
 
  /// Executes the Apple sign-in flow.
  ///
  /// Returns [Right] with a [UserEntity] on success, or [Left] with
  /// a [Failure] if the flow is cancelled or fails.
  Future<Either<Failure, UserEntity>> call() {
    return repository.signInWithApple();
  }
}
