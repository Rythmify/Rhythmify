import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/presentation/providers/current_user_id_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/mark_as_read_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/send_message_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/unread_messages_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/message_bubble.dart';
import 'package:rythmify/features/messaging/presentation/widgets/message_input_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Conversation conv;

  const ChatScreen({
    super.key,
    required this.conv,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController controller;
  final Set<String> _markedAsRead = {};

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final myId=ref.watch(currentUserIdProvider);

    final msgProvider=ref.watch(
      messageProvider(widget.conv.conversationId),
    );

    final unreadMsgProvider=ref.watch(
      unreadProvider(widget.conv.conversationId),
    );

    return Scaffold(
      key: const Key('chat_screen_scaffold'),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        key: const Key('chat_screen_app_bar'),
        title: Text(
          widget.conv.participantName,
          key: const Key('chat_participant_name_text'),
        ),
        backgroundColor: Colors.black,
      ),
      body:msgProvider.when(
        data:(msg){
          unreadMsgProvider.whenData((unreads){
            Future.microtask(() async{
            final unreads=await ref.read(unreadProvider(widget.conv.conversationId).future);
            for(final unread in unreads){
              await ref.read(markAsRead.notifier).markRead(
                msgId:unread.messageId,
                convId:unread.conversationId
              );
              await Future.delayed(const Duration(microseconds: 500));
              ref.refresh(conversationProvider);
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
              return MessageBubble(myId: myId,
              senderId: message.senderId,
              sentAt: message.createdAt,
              userAvatar: widget.conv.participantAvatar,
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
            onSubmitted: (text)async {
          if(controller.text.trim().isEmpty) return;
          await ref.read(sendMessageProvider.notifier).sendMessage(
            conversationId:widget.conv.conversationId,
            body:text.trim()
          );
          
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