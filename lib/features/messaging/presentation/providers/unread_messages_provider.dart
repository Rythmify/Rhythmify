import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/presentation/providers/current_user_id_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_notifier.dart';

/// Provider for the list of unread messages in a specific conversation.
final unreadProvider = FutureProvider.family<List<Message>, String>((
  ref,
  conversationId,
) async {
  final myId = ref.watch(currentUserIdProvider);
  final msgState = ref.watch(messagesNotifierProvider(conversationId));
  return msgState.messages.where((msg) {
    return msg.senderId != myId && !msg.isRead;
  }).toList();
});
