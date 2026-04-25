import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';

/// Returns the total number of unread notifications for the authenticated user.
class GetUnreadCountUsecase {
  final NotificationsRepoInterface repo;
  GetUnreadCountUsecase(this.repo);

  Future<int> call() => repo.getUnreadCount();
}
