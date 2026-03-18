import 'package:flutter/material.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/presentation/pages/chat_screen.dart';
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
      return ConversationTile(participantAvatar: conv.participantAvatar,
      participantName: conv.participantName,
      lastMessagePreview: conv.lastMessagePreview!,
      lastMessageDate: conv.lastMessageDate!,
      unreadCount: conv.unReadCount,
      onTap: (){
        Navigator.push(context,
        MaterialPageRoute(builder: (_)=>ChatScreen(conv: conv),
        ));
      },
      );
      },
    );
  }
}