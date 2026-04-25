import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';

/// Returns `true` if the authenticated user follows [userId].
///
/// Used by [FollowStateNotifier] to seed the follow state cache when
/// follow-type notifications are loaded.
class GetFollowStatusUsecase {
  final NotificationsRepoInterface repo;
  GetFollowStatusUsecase(this.repo);

  Future<bool> call(String userId) => repo.getFollowStatus(userId);
}
