import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationsRepoInterface {
  Future<({List<NotificationEntity> items, int unreadCount, bool hasNext})>
  getNotifications({int page, int limit, bool? unreadOnly});

  Future<int> getUnreadCount();
  Future<void> markNotificationAsRead(String notificationId);
  Future<bool> getFollowStatus(String userId);
}
