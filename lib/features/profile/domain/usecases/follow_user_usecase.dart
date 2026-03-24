import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

/// Use case that follows a user by their ID.
///
/// Delegates to [ProfileRepository.followUser].
class FollowUserUseCase {
  /// The repository used to follow the user.
  final ProfileRepository repository;

  /// Creates a [FollowUserUseCase] with the given [repository].
  FollowUserUseCase(this.repository);

  /// Follows the user identified by [userId].
  ///
  /// Returns [Right] with `void` on success, or [Left] with a [Failure].
  Future<Either<Failure, void>> call({required String userId}) {
    return repository.followUser(userId: userId);
  }
}
