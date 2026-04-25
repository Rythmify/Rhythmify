import 'package:rythmify/features/notifications/data/datasources/notification_remote_datasources.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';
import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';

/// Data-layer implementation of [NotificationsRepoInterface].
///
/// All methods are thin delegates to [NotificationRemoteDatasources].
class NotificationsRepoImpl implements NotificationsRepoInterface {
  final NotificationRemoteDatasources datasource;
  NotificationsRepoImpl(this.datasource);

  @override
  Future<({List<NotificationEntity> items, int unreadCount, bool hasNext})>
  getNotifications({int page = 1, int limit = 20, bool? unreadOnly}) =>
      datasource.getNotifications(
        page: page,
        limit: limit,
        unreadOnly: unreadOnly,
      );

  @override
  Future<int> getUnreadCount() => datasource.getUnreadCount();

  @override
  Future<void> markNotificationAsRead(String notificationId) =>
      datasource.markNotificationAsRead(notificationId);

  @override
  Future<bool> getFollowStatus(String userId) =>
      datasource.getFollowStatus(userId);
}
