import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';

class GetFollowStatusUsecase {
  final NotificationsRepoInterface repo;
  GetFollowStatusUsecase(this.repo);

  Future<bool> call(String userId) => repo.getFollowStatus(userId);
}