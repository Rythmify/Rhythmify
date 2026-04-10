import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/presentation/providers/un_block_notifier.dart';

/// Provider for the [BlockUserNotifier] that handles user blocking.
///
/// This provider manages the loading state ([bool]) during the block operation.
///
/// Depends on [BlockUserNotifier].
final unBlockProvider = StateNotifierProvider<UnblockNotifier, bool>((ref) {
  return UnblockNotifier(ref: ref);
});
