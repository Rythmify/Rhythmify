import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/presentation/providers/send_message_notifier.dart';

/// Provider for the [SendMessageNotifier] that handles message sending operations.
///
/// This provider manages the loading state ([bool]) while a message is being 
/// processed and provides access to methods for sending messages.
///
/// Depends on [SendMessageNotifier].
final sendMessageProvider = StateNotifierProvider<SendMessageNotifier, bool>((
  ref,
) {
  return SendMessageNotifier(ref: ref);
});
