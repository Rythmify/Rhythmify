import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifications_provider.dart';

/// Badge count shown in the app bar / tab bar.
///
/// Derived from [notificationsProvider] so it drops to zero immediately
/// after the notifications page opens and marks everything as read.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});
