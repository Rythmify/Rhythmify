import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/presentation/providers/current_user_id_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/mark_as_read_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/send_message_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/unread_messages_provider.dart';
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
    // Watch our required providers
    final myId = ref.watch(currentUserIdProvider);
    final msgProvider = ref.watch(messageProvider(widget.conv.conversationId));
    final unreadmsgProvider = ref.watch(unreadProvider(widget.conv.conversationId));

    return Scaffold(
      key: const Key('chat_screen_scaffold'),
      backgroundColor: Colors.black,
      appBar: AppBar(
        key: const Key('chat_screen_app_bar'),
        title: Text(
          widget.conv.participantName,
          key: const Key('chat_participant_name_text'),
        ),
        backgroundColor: Colors.black,
      ),
      body: msgProvider.when(
        data: (msg) {
          // Handle marking messages as read in the background
          unreadmsgProvider.whenData((unreads) {
            Future.microtask(() async {
              for (final unread in unreads) {
                await ref.read(markAsRead.notifier).markRead(
                      msgId: unread.messageId,
                      convId: unread.conversationId,
                    );
              }
            });
          });

          return Column(
            key: const Key('chat_main_column'),
            children: [
              // 1. The scrollable list of messages
              Expanded(
                child: ListView.builder(
                  key: const Key('chat_message_list_view'),
                  itemCount: msg.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemBuilder: (context, index) {
                    final message = msg[index];
                    return MessageBubble(
                      // Dynamic key using the message ID for specific test targeting
                      key: Key('chat_message_bubble_${message.messageId}'),
                      myId: myId,
                      senderId: message.senderId,
                      sentAt: message.createdAt,
                      userAvatar: widget.conv.participantAvatar,
                      body: message.body,
                    );
                  },
                ),
              ),
              
              // 2. The input area (Text field and Add button)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('chat_add_attachment_icon_button'),
                      onPressed: () {
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MessageInputBubble(
                        key: const Key('chat_message_input_bubble'),
                        controller: controller,
                        onSubmitted: (text) async {
                          if (controller.text.trim().isEmpty) return;
                          
                          await ref.read(sendMessageProvider.notifier).sendMessage(
                                conversationId: widget.conv.conversationId,
                                body: text.trim(),
                              );
                              
                          controller.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 65), // Spacing for Bottom Navigation Bar
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: Key('chat_loading_indicator'),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            error.toString(),
            key: const Key('chat_error_text'),
          ),
        ),
      ),
    );
  }
}