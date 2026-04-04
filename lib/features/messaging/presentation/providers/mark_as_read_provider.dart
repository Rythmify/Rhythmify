import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/presentation/providers/mark_as_read_notifier.dart';

/// Provider for the [MarkAsReadNotifier] that handles marking messages as read.
///
/// This provider manages the loading state ([bool]) during the update operation.
///
/// Depends on [MarkAsReadNotifier].
final markAsRead = StateNotifierProvider<MarkAsReadNotifier, bool>((ref) {
  return MarkAsReadNotifier(ref: ref);
});
