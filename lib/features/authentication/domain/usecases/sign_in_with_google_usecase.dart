import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case that signs in a user using their Google account via Firebase OAuth.
///
/// Delegates to [AuthRepository.signInWithGoogle].
class SignInWithGoogleUseCase {
  /// The repository used to perform Google sign-in.
  final AuthRepository repository;

  /// Creates a [SignInWithGoogleUseCase] with the given [repository].
  SignInWithGoogleUseCase(this.repository);

  /// Executes the Google sign-in flow.
  ///
  /// Returns [Right] with a [UserEntity] on success, or [Left] with
  /// a [Failure] if the flow is cancelled or fails.
  Future<Either<Failure, UserEntity>> call() {
    return repository.signInWithGoogle();
  }
}
