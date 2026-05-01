import 'package:dio/dio.dart';
import 'package:rythmify/features/notifications/data/datasources/notification_remote_datasources.dart';
import 'package:rythmify/features/notifications/data/models/notification_model.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

/// HTTP implementation of [NotificationRemoteDatasources] using Dio.
///
/// All endpoints are relative to the base URL configured in [ApiClient].
class NotificationDatasourcesImpl implements NotificationRemoteDatasources {
  final Dio dio;

  NotificationDatasourcesImpl(this.dio);

  @override
  /// Fetches a paginated list of notifications from `GET /notifications`.
  ///
  /// [newPostByFollowed] notifications are filtered out at this layer — they
  /// have no dedicated UI tile. Pagination state is derived from `has_next`
  /// inside the `pagination` sub-object.
  Future<({List<NotificationModel> items, int unreadCount, bool hasNext})>
  getNotifications({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
    String? type,
  }) async {
    final result = await dio.get(
      '/notifications',
      queryParameters: {
        'page': page,
        'limit': limit,
        'unread_only': ?unreadOnly,
        'type': ?type,
      },
    );

    final data = result.data['data'] as Map<String, dynamic>;
    final List rawItems = data['items'] as List? ?? [];
    final pagination = data['pagination'] as Map<String, dynamic>? ?? {};

    // new_post_by_followed has no dedicated UI — filtered out at the data layer.
    final items = rawItems
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .where((n) => n.type != NotificationType.newPostByFollowed)
        .toList();

    return (
      items: items,
      unreadCount: data['unread_count'] as int? ?? 0,
      hasNext: pagination['has_next'] as bool? ?? false,
    );
  }

  @override
  /// Returns the unread notification count from `GET /notifications/unread-count`.
  Future<int> getUnreadCount() async {
    final result = await dio.get('/notifications/unread-count');
    return result.data['data']['unread_count'] as int;
  }

  @override
  /// Marks [notificationId] as read via `PATCH /notifications/{id}/read`.
  ///
  /// Called fire-and-forget from [NotificationsNotifier]; errors are not surfaced to the UI.
  Future<void> markNotificationAsRead(String notificationId) async {
    await dio.patch('/notifications/$notificationId/read');
  }

  @override
  /// Returns whether the current user follows [userId] via `GET /users/{userId}/follow-status`.
  ///
  /// Defaults to `false` when the `is_following` field is absent.
  Future<bool> getFollowStatus(String userId) async {
    final result = await dio.get('/users/$userId/follow-status');
    return result.data['data']['is_following'] as bool? ?? false;
  }

  @override
  /// Returns the `track_id` and `is_liked_by_me` for [commentId] via `GET /comments/{commentId}`.
  ///
  /// Used when tapping a comment notification to resolve the parent track for navigation.
  Future<({String? trackId, bool isLikedByMe})> getTrackIdByCommentId(
    String commentId,
  ) async {
    final result = await dio.get('/comments/$commentId');
    final data = result.data['data'] as Map<String, dynamic>;
    return (
      trackId: data['track_id'] as String?,
      isLikedByMe: data['is_liked_by_me'] as bool? ?? false,
    );
  }
}
