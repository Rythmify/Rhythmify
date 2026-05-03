import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case that sends a verification email to the current user.
///
/// Delegates to [AuthRepository.sendVerificationEmail].
class SendVerificationEmailUseCase {
  /// The repository used to dispatch the verification email.
  final AuthRepository repository;

  /// Creates a [SendVerificationEmailUseCase] with the given [repository].
  SendVerificationEmailUseCase(this.repository);

  /// Sends the email verification link.
  ///
  /// Returns [Right] with `void` on success, or [Left] with a
  /// [Failure] if the request fails.
  Future<Either<Failure, void>> call() {
    return repository.sendVerificationEmail();
  }
}
