import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case that sends a password reset email to a given address.
///
/// Delegates to [AuthRepository.sendPasswordReset].
class SendPasswordResetUseCase {
  /// The repository used to dispatch the password reset email.
  final AuthRepository repository;
 
  /// Creates a [SendPasswordResetUseCase] with the given [repository].
  SendPasswordResetUseCase(this.repository);
 
  /// Sends the password reset email.
  ///
  /// Returns [Right] with `void` on success, or [Left] with a
  /// [Failure] (e.g. [InvalidCredentialsFailure]) if the email is
  /// not registered.
  ///
  /// [email] — the email address of the account to reset.
  Future<Either<Failure, void>> call({required String email}) {
    return repository.sendPasswordReset(email: email);
  }
}
 
