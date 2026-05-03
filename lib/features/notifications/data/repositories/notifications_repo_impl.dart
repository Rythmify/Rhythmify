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
  /// Fetches a paginated page of notifications.
  ///
  /// Delegates to [NotificationRemoteDatasources.getNotifications].
  Future<({List<NotificationEntity> items, int unreadCount, bool hasNext})>
  getNotifications({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
    String? type,
  }) => datasource.getNotifications(
    page: page,
    limit: limit,
    unreadOnly: unreadOnly,
    type: type,
  );

  @override
  /// Returns the total count of unread notifications.
  Future<int> getUnreadCount() => datasource.getUnreadCount();

  @override
  /// Marks the notification identified by [notificationId] as read.
  Future<void> markNotificationAsRead(String notificationId) =>
      datasource.markNotificationAsRead(notificationId);

  @override
  /// Returns `true` if the current user follows [userId].
  Future<bool> getFollowStatus(String userId) =>
      datasource.getFollowStatus(userId);

  @override
  /// Returns the `track_id` and `is_liked_by_me` for the given [commentId].
  ///
  /// Used when tapping a comment notification to navigate to the correct track.
  Future<({String? trackId, bool isLikedByMe})> getTrackIdByCommentId(
    String commentId,
  ) => datasource.getTrackIdByCommentId(commentId);
}
