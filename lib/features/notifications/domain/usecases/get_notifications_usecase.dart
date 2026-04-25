import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';
import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';

class GetNotificationsUsecase {
  final NotificationsRepoInterface repo;
  GetNotificationsUsecase(this.repo);

  Future<({List<NotificationEntity> items, int unreadCount, bool hasNext})>
  call({int page = 1, int limit = 20, bool? unreadOnly}) =>
      repo.getNotifications(page: page, limit: limit, unreadOnly: unreadOnly);
}
