import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/presentation/providers/block_user_notifier.dart';

/// Provider for the [BlockUserNotifier] that handles user blocking.
///
/// This provider manages the loading state ([bool]) during the block operation.
///
/// Depends on [BlockUserNotifier].
final blockUserProvider = StateNotifierProvider<BlockUserNotifier, bool>((ref) {
  return BlockUserNotifier(ref: ref);
});
