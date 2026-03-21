import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/presentation/widgets/conversation_tile.dart';

class InboxConversations extends StatelessWidget{
  final List<Conversation> conversations;

  const InboxConversations({
    super.key,
    required this.conversations
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
      final conv=conversations[index];
      return ConversationTile(
      key: Key('messaging_inbox_item_${conv.participantName}_tile'),
      participantAvatar: conv.participantAvatar,
      participantName: conv.participantName,
      lastMessagePreview: conv.lastMessagePreview!,
      lastMessageDate: conv.lastMessageDate!,
      unreadCount: conv.unReadCount,
      onTap: (){
        //context.go('/home/inbox/chat/${conv.conversationId}');
        context.go('/home/inbox/chat/${conv.conversationId}',
        extra: conv);
      },
      );
      },
    );
  }
}