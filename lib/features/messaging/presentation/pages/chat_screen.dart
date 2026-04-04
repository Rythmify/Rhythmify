import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/presentation/providers/current_user_id_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_by_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/mark_as_read_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/send_message_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/unread_messages_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/blocked_by_widget.dart';
import 'package:rythmify/features/messaging/presentation/widgets/blocked_user_widget.dart';
import 'package:rythmify/features/messaging/presentation/widgets/message_bubble.dart';
import 'package:rythmify/features/messaging/presentation/widgets/message_input_bubble.dart';
import 'package:rythmify/features/messaging/presentation/widgets/pop_up_menu_widget.dart';

/// A screen that displays the chat conversation between users.
///
/// This screen handles fetching and displaying messages, marking them as read,
/// and sending new messages. It supports both existing conversations and
/// starting new ones with a participant.
class ChatScreen extends ConsumerStatefulWidget {
  final Conversation? conv;
  final String? newParticipantName;
  final String? newParticipantId;

  const ChatScreen({
    super.key,
    this.conv,
    this.newParticipantName,
    this.newParticipantId,
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
    final myId = ref.watch(currentUserIdProvider);

    final msgProvider = widget.conv != null
        ? ref.watch(messageProvider(widget.conv!.conversationId))
        : null;

    final unreadMsgProvider = widget.conv != null
        ? ref.watch(unreadProvider(widget.conv!.conversationId))
        : null;

    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    final isBlockedAsync = ref.watch(isBlockedProvider(widget.conv?.participantId ?? widget.newParticipantId!));
    final bool isBlocked = isBlockedAsync.value ?? false;

    final isBlockedByAsync = ref.watch(isBlockedByProvider(widget.conv?.participantId ?? widget.newParticipantId!));
    final bool isBlockedBy = isBlockedByAsync.value ?? false;

    return Scaffold(
      key: const Key('chat_screen_scaffold'),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        key: const Key('chat_screen_app_bar'),
        title: Text(
          widget.conv?.participantName ?? widget.newParticipantName ?? '',
          key: const Key('chat_participant_name_text'),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: (){
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => 
                  PopUpMenuWidget(
                    participantId: widget.conv?.participantId ?? widget.newParticipantId!,
                    parentContext: context
                  ),
                backgroundColor: const Color(0xFF121212),
              );
            },
            icon: const Icon( Icons.more_vert, color: Colors.white)
          )
        ]
      ),
      body: widget.conv == null
          ? _blanckChatPage()
          : msgProvider!.when(
              data: (msg) {
                unreadMsgProvider!.whenData((unreads) {
                  Future.microtask(() async {
                    final unreads = await ref.read(
                      unreadProvider(widget.conv!.conversationId).future,
                    );
                    for (final unread in unreads) {
                      await ref
                          .read(markAsRead.notifier)
                          .markRead(
                            msgId: unread.messageId,
                            convId: unread.conversationId,
                          );
                      await Future.delayed(const Duration(microseconds: 500));
                      ref.invalidate(conversationProvider);
                    }
                  });
                });
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: msg.length,
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 12,
                          bottom: 150,
                        ),
                        itemBuilder: (context, index) {
                          final message = msg[index];
                          return MessageBubble(
                            myId: myId,
                            senderId: message.senderId,
                            sentAt: message.createdAt,
                            userAvatar: widget.conv!.participantAvatar,
                            body: message.body,
                          );
                        },
                      ),
                    ),
                    isBlocked ? BlockedUserWidget(participantId: widget.conv?.participantId ?? widget.newParticipantId!)
                      :isBlockedBy ? const BlockedByWidget()
                        :Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: isKeyboardOpen ? 10 : 80, // 85 (NavBar) + 16
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                context.push('/home/inbox/chat/${widget.conv!.conversationId}/likes-playlists');
                              },
                              icon: const Icon(Icons.add_outlined, color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MessageInputBubble(
                                controller: controller,
                                onSubmitted: (text) async {
                                  if (controller.text.trim().isEmpty) return;
                                  await ref
                                      .read(sendMessageProvider.notifier)
                                      .sendMessage(
                                        conversationId:
                                            widget.conv!.conversationId,
                                        body: text.trim(),
                                      );

                                  controller.clear();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text(error.toString())),
            ),
    );
  }

  Widget _blanckChatPage() {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Column(
      children: [
        Expanded(child: const SizedBox()),
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: isKeyboardOpen ? 16 : 101, // 85 (NavBar) + 16
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  context.push('/home/inbox/chat/new/likes-playlists');
                },
                icon: const Icon(Icons.add_outlined, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MessageInputBubble(
                  controller: controller,
                  onSubmitted: (text) async {
                    if (controller.text.trim().isEmpty) return;
                    final newConv = await ref
                        .read(sendMessageProvider.notifier)
                        .sendMessage(
                          newParticipantId: widget.newParticipantId,
                          body: text.trim(),
                        );
                    controller.clear();

                    if (!mounted) return;

                    if (newConv != null) {
                      context.go(
                        '/home/inbox/chat/${newConv.conversationId}',
                        extra: newConv,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
