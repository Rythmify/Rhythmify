import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';

class GetUnreadCountUsecase {
  final NotificationsRepoInterface repo;
  GetUnreadCountUsecase(this.repo);

  Future<int> call() => repo.getUnreadCount();
}
