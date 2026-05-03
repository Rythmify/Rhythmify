import '../entities/follow_status.dart';
import '../repositories/profile_repository.dart';

/// Retrieves the relationship status between the authenticated user
/// and a given target user.
///
/// Used primarily on the profile page to determine whether to render
/// a blocked screen (`isBlocking == true`) or the full profile.
class GetFollowStatusUseCase {
  /// The repository used to fetch follow/block status from the API.
  final ProfileRepository _repository;

  /// Creates a [GetFollowStatusUseCase] with the given [repository].
  const GetFollowStatusUseCase(this._repository);

  /// Executes the use case for the user identified by [userId].
  ///
  /// Returns a [FollowStatus] describing the relationship.
  /// Returns [FollowStatus.empty] on error to avoid crashing the UI.
  Future<FollowStatus> call(String userId) async {
    try {
      return await _repository.getFollowStatus(userId);
    } catch (_) {
      return FollowStatus.empty;
    }
  }
}
