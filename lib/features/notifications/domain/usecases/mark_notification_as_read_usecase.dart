import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';

class MarkNotificationAsReadUsecase {
  final NotificationsRepoInterface repo;
  MarkNotificationAsReadUsecase(this.repo);

  Future<void>call(String notificationId) =>
      repo.markNotificationAsRead(notificationId);
}

