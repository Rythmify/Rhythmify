import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

/// Domain contract for notification data access.
///
/// Sits between the domain use cases and the data layer.
/// All methods delegate to [NotificationRemoteDatasources] via [NotificationsRepoImpl].
abstract class NotificationsRepoInterface {
  /// Fetches a paginated page of notifications.
  ///
  /// Returns the [items] list, the total [unreadCount], and [hasNext].
  Future<({List<NotificationEntity> items, int unreadCount, bool hasNext})>
  getNotifications({int page, int limit, bool? unreadOnly, String? type});

  /// Returns the number of unread notifications.
  Future<int> getUnreadCount();

  /// Marks a single notification as read on the backend.
  Future<void> markNotificationAsRead(String notificationId);

  /// Returns `true` if the authenticated user follows [userId].
  Future<bool> getFollowStatus(String userId);

  /// Returns the `track_id` for the comment identified by [commentId].
  Future<({String? trackId, bool isLikedByMe})> getTrackIdByCommentId(
    String commentId,
  );
}
