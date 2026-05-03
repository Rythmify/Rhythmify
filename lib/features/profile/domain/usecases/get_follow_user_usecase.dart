import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

/// Use case that follows a user by their ID.
///
/// Delegates to [ProfileRepository.followUser].
class GetFollowUserUseCase {
  /// The repository used to follow the user.
  final ProfileRepository repository;

  /// Creates a [GetFollowUserUseCase] with the given [repository].
  GetFollowUserUseCase(this.repository);

  /// Follows the user identified by [userId].
  ///
  /// Returns [Right] with `void` on success, or [Left] with a [Failure].
  Future<Either<Failure, void>> call({required String userId}) {
    return repository.followUser(userId: userId);
  }
}
