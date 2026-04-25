import 'package:rythmify/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDatasources {
  Future<({List<NotificationModel> items, int unreadCount, bool hasNext})>
  getNotifications({int page, int limit, bool? unreadOnly});

  Future<int> getUnreadCount();
  Future<void> markNotificationAsRead(String notificationId);
}
