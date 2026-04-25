import 'package:rythmify/features/notifications/data/models/notification_model.dart';

/// Contract for all notification-related remote data operations.
abstract class NotificationRemoteDatasources {
  /// Fetches a paginated list of notifications for the authenticated user.
  ///
  /// Returns the [items] for [page], the total [unreadCount] across all pages,
  /// and [hasNext] indicating whether more pages exist.
  /// Pass [unreadOnly] as `true` to restrict results to unread notifications only.
  Future<({List<NotificationModel> items, int unreadCount, bool hasNext})>
  getNotifications({int page, int limit, bool? unreadOnly, String? type});

  /// Returns the total count of unread notifications for the authenticated user.
  Future<int> getUnreadCount();

  /// Marks the notification identified by [notificationId] as read via
  /// `PATCH /notifications/{id}/read`. Called fire-and-forget.
  Future<void> markNotificationAsRead(String notificationId);

  /// Returns `true` if the authenticated user follows [userId].
  ///
  /// Calls `GET /users/{userId}/follow-status` and extracts `is_following`.
  Future<bool> getFollowStatus(String userId);

  /// Returns the `track_id` for the comment identified by [commentId].
  ///
  /// Calls `GET /comments/{commentId}` and extracts `track_id`.
  Future<({String? trackId,bool isLikedByMe})> getTrackIdByCommentId(String commentId);
}
