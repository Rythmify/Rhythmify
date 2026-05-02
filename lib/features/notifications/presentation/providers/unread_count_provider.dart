import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'repo_provider.dart';

final unreadNotificationsCountProvider = FutureProvider<int>((ref) {
  final repo = ref.watch(repositoryprovider);
  return GetUnreadCountUsecase(repo).call();
});
