import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/discord_auth_data.dart';
import '../repositories/auth_repository.dart';

/// Triggers the GitHub OAuth sign-in flow.
///
/// Delegates to [AuthRepository.loginWithGitHub] which opens the system
/// browser, waits for the deep-link callback, and exchanges the code with
/// the backend.
///
/// Returns [Right] with [GitHubAuthData] on success.
/// Returns [Left] with [GitHubAuthFailure] if cancelled or rejected.
class LoginWithGitHubUseCase {
  final AuthRepository _repository;

  /// Creates a [LoginWithGitHubUseCase] with the given [repository].
  const LoginWithGitHubUseCase(AuthRepository repository)
    : _repository = repository;

  /// Executes the GitHub OAuth flow.
  Future<Either<Failure, GitHubAuthData>> call() =>
      _repository.loginWithGitHub();
}
