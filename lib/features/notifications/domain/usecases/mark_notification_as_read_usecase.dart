import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';

/// Marks a single notification as read on the backend.
///
/// Called fire-and-forget for every unread notification after fetch and loadMore.
/// Failures are silently ignored to avoid disrupting the UI.
class MarkNotificationAsReadUsecase {
  final NotificationsRepoInterface repo;
  MarkNotificationAsReadUsecase(this.repo);

  Future<void> call(String notificationId) =>
      repo.markNotificationAsRead(notificationId);
}
