import 'package:dio/dio.dart';
import 'package:rythmify/features/notifications/data/datasources/notification_remote_datasources.dart';
import 'package:rythmify/features/notifications/data/models/notification_model.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';

/// HTTP implementation of [NotificationRemoteDatasources].
class NotificationDatasourcesImpl implements NotificationRemoteDatasources {
  final Dio dio;
  NotificationDatasourcesImpl(this.dio);

  @override
  Future<({List<NotificationModel> items, int unreadCount, bool hasNext})>
  getNotifications({int page = 1, int limit = 20, bool? unreadOnly}) async {
    final result = await dio.get(
      '/notifications',
      queryParameters: {
        'page': page,
        'limit': limit,
        'unread_only': ?unreadOnly,
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
  Future<int> getUnreadCount() async {
    final result = await dio.get('/notifications/unread-count');
    return result.data['data']['unread_count'] as int;
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await dio.patch('/notifications/$notificationId/read');
  }

  @override
  Future<bool> getFollowStatus(String userId) async {
    final result = await dio.get('/users/$userId/follow-status');
    return result.data['data']['is_following'] as bool? ?? false;
  }
}
