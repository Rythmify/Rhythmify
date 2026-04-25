import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/notifications/data/datasources/notification_datasources_impl.dart';
import 'package:rythmify/features/notifications/data/repositories/notifications_repo_impl.dart';
import 'package:rythmify/features/notifications/domain/repositories/notifications_repo_interface.dart';

/// Provides the singleton [NotificationsRepoInterface] used across all
/// notification use cases and notifiers.
final repositoryprovider = Provider<NotificationsRepoInterface>((ref) {
  final datasource = NotificationDatasourcesImpl(apiClient.dio);
  return NotificationsRepoImpl(datasource);
});
