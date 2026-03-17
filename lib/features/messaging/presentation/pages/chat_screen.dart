import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/presentation/providers/mark_as_read_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/send_message_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/unread_messages_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/message_bubble.dart';
import 'package:rythmify/features/messaging/presentation/widgets/message_input_bubble.dart';

class ChatScreen extends ConsumerWidget {
  final Conversation conv;

  const ChatScreen({
    super.key,
    required this.conv
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final msgProvider=ref.watch(
      messageProvider(conv.conversationId),
    );

    final unreadmsgProvider=ref.watch(
      unreadProvider(conv.conversationId),
    );
    
    final controller =TextEditingController();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(conv.participantName),
        backgroundColor: Colors.black,
      ),
      body:msgProvider.when(
        data:(msg){
          unreadmsgProvider.whenData((unreads){
          Future.microtask(()async{
            for(final unread in unreads)
            {
              await ref.read(markAsRead.notifier).markRead(msgId: unread.messageId, convId: unread.conversationId);
            }
          });
        });
        return Column(
        children: [
          Expanded(child: ListView.builder(
            itemCount: msg.length,
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
            itemBuilder: (context,index){
              final message=msg[index];
              return MessageBubble(myId: 'current_user',
              senderId: message.senderId,
              sentAt: message.createdAt,
              userAvatar: conv.participantAvatar,
              body: message.body);
            }
          
          )
         
        ),
        Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(children: [
          IconButton(onPressed: (){},
          icon:const Icon(Icons.add,color:Colors.white)
          ),
          const SizedBox(width: 8),
          Expanded(child: MessageInputBubble(
            controller: controller,
            onSubmitted: (text)async {////////////////////////////////////////////
          if(controller.text.trim().isEmpty) return;
          final newMessage = Message(
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
          senderId: 'current_user',
          conversationId: conv.conversationId,
          body: text.trim(),
          embedId: null,
          embedType: null,
          isRead: true,
          createdAt: DateTime.now(),
        );
///////////////////////////////////////////////////////////////////////////////////////
  await ref.read(sendMessageProvider.notifier).sendMessage(msg: newMessage);

  controller.clear();
},
),)
        ],),
        )
        ],
      );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Text(error.toString()),
      ),
      )
    );
  }
}