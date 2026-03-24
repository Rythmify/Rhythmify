import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/presentation/providers/current_user_id_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_provider.dart';

/// Provider for the list of unread messages in a specific conversation.
///
/// This provider filters the messages fetched by [messageProvider] to include
/// only those not sent by the current user (identified by [currentUserIdProvider])
/// and having an `isRead` status of false.
///
/// Depends on [currentUserIdProvider] and [messageProvider].
final unreadProvider = FutureProvider.family<List<Message>, String>((
  ref,
  conversationId,
) async {
  final myId = ref.watch(currentUserIdProvider);
  final messages = await ref.watch(messageProvider(conversationId).future);
  return messages.where((msg) {
    return msg.senderId != myId && !msg.isRead;
  }).toList();
});
