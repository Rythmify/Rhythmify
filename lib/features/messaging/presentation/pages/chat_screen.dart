import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/data/datasources/data_sources_sockets.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/presentation/providers/current_user_id_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_by_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/mark_as_read_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/send_message_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/socket_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/unread_messages_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/blocked_by_widget.dart';
import 'package:rythmify/features/messaging/presentation/widgets/blocked_user_widget.dart';
import 'package:rythmify/features/messaging/presentation/widgets/message_bubble.dart';
import 'package:rythmify/features/messaging/presentation/widgets/message_input_bubble.dart';
import 'package:rythmify/features/messaging/presentation/widgets/pop_up_menu_widget.dart';
import 'package:rythmify/features/messaging/presentation/widgets/selected_embeds_preview_widget.dart';

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
  final List<SharedEmbed> _selectedEmbeds = [];
  late DataSourcesSockets _socket;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    _socket = ref.read(socketProvider);
    if (widget.conv != null) {
      Future.microtask(() {
        if (!mounted) return;
        ref.invalidate(messageProvider(widget.conv!.conversationId));
        ref.invalidate(conversationProvider);
        if(widget.conv!.participantId.isNotEmpty){
          ref.invalidate(isBlockedProvider(widget.conv!.participantId));
          ref.invalidate(isBlockedByProvider(widget.conv!.participantId));
        }
        _socket.joinConversation(widget.conv!.conversationId);
        _setupSocketListeners(widget.conv!.conversationId);
        _socket.setOnReconnectedToRoom(() {
          if (mounted) _setupSocketListeners(widget.conv!.conversationId);
        });
      });
    }
  }

  void _setupSocketListeners(String conversationId) {
    _socket.onMessageReceived((data) {
      print('🔥 onMessageReceived fired: $data');
      if (mounted) {
        ref.invalidate(messageProvider(conversationId));
        ref.invalidate(conversationProvider);
      }
    });
    _socket.onMessageReadUpdated((data) {
      if (mounted) {
        ref.invalidate(messageProvider(conversationId));
      }
    });
  }

  @override
  void dispose() {
    if (widget.conv != null) {
      _socket.leaveConversation(widget.conv!.conversationId);
    }
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

    final participantId = widget.conv?.participantId ?? widget.newParticipantId;

    final isBlockedAsync = participantId != null
        ? ref.watch(isBlockedProvider(participantId))
        : const AsyncValue<bool>.data(false);
    final bool isBlocked = isBlockedAsync.value ?? false;

    final isBlockedByAsync = participantId != null
        ? ref.watch(isBlockedByProvider(participantId))
        : const AsyncValue<bool>.data(false);
    final bool isBlockedBy = isBlockedByAsync.value ?? false;

    return Scaffold(
      key: const Key('chat_screen_scaffold'),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        key: const Key('chat_screen_app_bar'),
        title: Text(
          widget.conv?.participantName ?? widget.newParticipantName ?? 'Chat',
          key: const Key('chat_participant_name_text'),
        ),
        backgroundColor: Colors.black,
        actions: [
          if (participantId != null)
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => PopUpMenuWidget(
                    participantId: participantId,
                    parentContext: context,
                  ),
                  backgroundColor: const Color(0xFF121212),
                );
              },
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
        ],
      ),
      body: widget.conv == null
          ? _blanckChatPage(isBlocked: isBlocked, isBlockedBy: isBlockedBy)
          : msgProvider?.when(
                  data: (msg) {
                    unreadMsgProvider?.whenData((unreads) {
                      if (unreads.isNotEmpty) {
                        Future.microtask(() async {
                          if (!mounted) return;
                          final latestUnreads = await ref.read(
                            unreadProvider(widget.conv!.conversationId).future,
                          );
                          for (final unread in latestUnreads) {
                            if (!mounted) return;
                            await ref
                                .read(markAsRead.notifier)
                                .markRead(
                                  msgId: unread.messageId,
                                  convId: unread.conversationId,
                                );
                            await Future.delayed(
                              const Duration(microseconds: 500),
                            );
                            if (!mounted) return;
                            ref.invalidate(conversationProvider);
                          }
                        });
                      }
                    });
                    final groups = _groupMessages(msg);
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 12,
                              bottom: 150,
                            ),
                            itemCount: groups.length,
                            itemBuilder: (context, groupIndex) {
                              final group =
                                  groups[groups.length - 1 - groupIndex];
                              final isMe =
                                  group.isNotEmpty &&
                                  group.first.senderId == myId;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 22),
                                child: Column(
                                  crossAxisAlignment: isMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                                  children: [
                                    ...group.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final message = entry.value;
                                      final radius = _getBubbleRadius(
                                        isMe,
                                        index,
                                        group.length,
                                        message.embedType,
                                      );

                                      return MessageBubble(
                                        key: Key(
                                          'chat_screen_message_bubble_${message.messageId}',
                                        ),
                                        myId: myId,
                                        senderId: message.senderId,
                                        userAvatar: index == group.length - 1
                                            ? widget.conv?.participantAvatar
                                            : null,
                                        body: message.body,
                                        embedId: message.embedId,
                                        embedType: message.embedType,
                                        borderRadius: radius,
                                      );
                                    }),
                                    if (group.isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: isMe ? 0 : 46,
                                          right: isMe ? 8 : 0,
                                          top: 6,
                                        ),
                                        child: Text(
                                          _fixTime(group.last.createdAt),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        isBlocked && participantId != null
                            ? BlockedUserWidget(
                                key: const Key(
                                  'chat_screen_blocked_user_widget',
                                ),
                                participantId: participantId,
                              )
                            : isBlockedBy
                            ? const BlockedByWidget(
                                key: Key('chat_screen_blocked_by_widget'),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SelectedEmbedsPreviewWidget(
                                    key: const Key(
                                      'chat_screen_selected_embeds_preview',
                                    ),
                                    selectedEmbeds: _selectedEmbeds,
                                    onRemove: (index) => setState(() {
                                      if (index < _selectedEmbeds.length) {
                                        final removedPermalink =
                                            'https://rythmify.com/${_selectedEmbeds[index].embedType == 'track' ? 'tracks' : 'playlists'}/${_selectedEmbeds[index].embedName}';
                                        controller.text = controller.text
                                            .replaceAll(removedPermalink, '')
                                            .trim();
                                        _selectedEmbeds.removeAt(index);
                                      }
                                    }),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      top: 8,
                                      bottom: isKeyboardOpen
                                          ? 10
                                          : 80, // 85 (NavBar) + 16
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          key: const Key(
                                            'chat_screen_add_embed_button',
                                          ),
                                          onPressed: () async {
                                            if (widget.conv == null) return;
                                            final embeds = await context
                                                .push<List<SharedEmbed>>(
                                                  '/home/inbox/chat/${widget.conv!.conversationId}/likes-playlists',
                                                );
                                            if (embeds != null &&
                                                embeds.isNotEmpty) {
                                              setState(() {
                                                _selectedEmbeds.addAll(embeds);
                                                final addedPermalinks =
                                                    _buildPermalinks(embeds);
                                                final existing =
                                                    controller.text;
                                                controller.text =
                                                    existing.isEmpty
                                                    ? addedPermalinks
                                                    : '$existing\n$addedPermalinks';
                                                controller.selection =
                                                    TextSelection.fromPosition(
                                                      TextPosition(
                                                        offset: controller
                                                            .text
                                                            .length,
                                                      ),
                                                    );
                                              });
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.add_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: MessageInputBubble(
                                            key: const Key(
                                              'chat_screen_message_input',
                                            ),
                                            controller: controller,
                                          ),
                                        ),
                                        ValueListenableBuilder<
                                          TextEditingValue
                                        >(
                                          valueListenable: controller,
                                          builder: (context, value, child) {
                                            if (value.text.isEmpty) {
                                              return const SizedBox.shrink();
                                            }
                                            return IconButton(
                                              key: const Key(
                                                'chat_screen_send_button',
                                              ),
                                              onPressed: () async {
                                                await _sendInExistingConv();
                                              },
                                              icon: const Icon(
                                                Icons.send,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white54,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Failed to load messages',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed: () {
                            if (mounted && widget.conv != null) {
                              ref.invalidate(
                                messageProvider(widget.conv!.conversationId),
                              );
                            }
                          },
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                ) ??
                const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _blanckChatPage({required bool isBlocked, required bool isBlockedBy}) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Column(
      children: [
        Expanded(child: const SizedBox()),
        isBlocked
            ? BlockedUserWidget(
                key: const Key('chat_screen_blocked_user_widget'),
                participantId: widget.newParticipantId!,
              )
            : isBlockedBy
            ? const BlockedByWidget(key: Key('chat_screen_blocked_by_widget'))
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SelectedEmbedsPreviewWidget(
                    key: const Key('chat_screen_selected_embeds_preview'),
                    selectedEmbeds: _selectedEmbeds,
                    onRemove: (index) => setState(() {
                      final removedPermalink =
                          'https://rythmify.com/${_selectedEmbeds[index].embedType == 'track' ? 'tracks' : 'playlists'}/${_selectedEmbeds[index].embedName}';
                      controller.text = controller.text
                          .replaceAll(removedPermalink, '')
                          .trim();
                      _selectedEmbeds.removeAt(index);
                    }),
                  ),
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
                          key: const Key('chat_screen_add_embed_button'),
                          onPressed: () async {
                            final embeds = await context
                                .push<List<SharedEmbed>>(
                                  '/home/inbox/chat/new/likes-playlists',
                                );
                            if (embeds != null && embeds.isNotEmpty) {
                              setState(() {
                                _selectedEmbeds.addAll(embeds);
                                final addedPermalinks = _buildPermalinks(
                                  embeds,
                                );
                                final existing = controller.text;
                                controller.text = existing.isEmpty
                                    ? addedPermalinks
                                    : '$existing\n$addedPermalinks';
                                controller
                                    .selection = TextSelection.fromPosition(
                                  TextPosition(offset: controller.text.length),
                                );
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.add_outlined,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MessageInputBubble(
                            key: const Key('chat_screen_message_input'),
                            controller: controller,
                          ),
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller,
                          builder: (context, value, child) {
                            if (value.text.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return IconButton(
                              key: const Key('chat_screen_send_button'),
                              onPressed: () async {
                                await _sendInNewConv();
                              },
                              icon: const Icon(Icons.send, color: Colors.white),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  List<List<dynamic>> _groupMessages(List<dynamic> messages) {
    final groups = <List<dynamic>>[];
    if (messages.isEmpty) return groups;

    List<dynamic> currentGroup = [messages.first];

    for (int i = 1; i < messages.length; i++) {
      final prev = messages[i - 1];
      final curr = messages[i];

      final sameSender = curr.senderId == prev.senderId;
      final closeInTime =
          curr.createdAt.difference(prev.createdAt).inSeconds.abs() <= 5;

      if (sameSender && closeInTime) {
        currentGroup.add(curr);
      } else {
        groups.add(currentGroup);
        currentGroup = [curr];
      }
    }

    groups.add(currentGroup);
    return groups;
  }

  BorderRadius _getBubbleRadius(
    bool isMe,
    int index,
    int total,
    String? embedType,
  ) {
    const double rounded = 18;
    const double sharp = 4;

    // playlist/album — rectangular with rounded top on first, rounded bottom on last
    if (embedType == 'playlist' || embedType == 'album') {
      if (total == 1) return BorderRadius.circular(rounded);
      if (index == 0) {
        return const BorderRadius.only(
          topLeft: Radius.circular(rounded),
          topRight: Radius.circular(rounded),
          bottomLeft: Radius.circular(sharp),
          bottomRight: Radius.circular(sharp),
        );
      } else if (index == total - 1) {
        return const BorderRadius.only(
          topLeft: Radius.circular(sharp),
          topRight: Radius.circular(sharp),
          bottomLeft: Radius.circular(rounded),
          bottomRight: Radius.circular(rounded),
        );
      } else {
        return BorderRadius.zero;
      }
    }

    if (total == 1) return BorderRadius.circular(rounded);

    if (isMe) {
      if (index == 0) {
        return const BorderRadius.only(
          topLeft: Radius.circular(rounded),
          topRight: Radius.circular(rounded),
          bottomLeft: Radius.circular(rounded),
          bottomRight: Radius.circular(sharp),
        );
      } else if (index == total - 1) {
        return const BorderRadius.only(
          topLeft: Radius.circular(rounded),
          topRight: Radius.circular(sharp),
          bottomLeft: Radius.circular(rounded),
          bottomRight: Radius.circular(rounded),
        );
      } else {
        return const BorderRadius.only(
          topLeft: Radius.circular(rounded),
          topRight: Radius.circular(sharp),
          bottomLeft: Radius.circular(rounded),
          bottomRight: Radius.circular(sharp),
        );
      }
    } else {
      if (index == 0) {
        return const BorderRadius.only(
          topLeft: Radius.circular(rounded),
          topRight: Radius.circular(rounded),
          bottomLeft: Radius.circular(sharp),
          bottomRight: Radius.circular(rounded),
        );
      } else if (index == total - 1) {
        return const BorderRadius.only(
          topLeft: Radius.circular(sharp),
          topRight: Radius.circular(rounded),
          bottomLeft: Radius.circular(rounded),
          bottomRight: Radius.circular(rounded),
        );
      } else {
        return const BorderRadius.only(
          topLeft: Radius.circular(sharp),
          topRight: Radius.circular(rounded),
          bottomLeft: Radius.circular(sharp),
          bottomRight: Radius.circular(rounded),
        );
      }
    }
  }

  String _fixTime(DateTime date) {
    final duration = DateTime.now().difference(date);

    if (duration.inDays >= 365) {
      return '${duration.inDays ~/ 365} years ago';
    } else if (duration.inDays >= 30) {
      return '${duration.inDays ~/ 30} months ago';
    } else if (duration.inDays >= 7) {
      return '${duration.inDays ~/ 7} weeks ago';
    } else if (duration.inDays >= 1) {
      return '${duration.inDays ~/ 1} days ago';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours ~/ 1} hours ago';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes ~/ 1} minutes ago';
    } else {
      return '${duration.inSeconds} seconds ago';
    }
  }

  String _buildPermalinks(List<SharedEmbed> embeds) {
    return embeds
        .map(
          (e) =>
              'https://rythmify.com/${e.embedType == 'track' ? 'tracks' : 'playlists'}/${e.embedName}',
        )
        .join('\n');
  }

  Future<void> _processAndSendMessages(
    String conversationId,
    String text,
  ) async {
    final trackUrlRegex = RegExp(
      r'https://rythmify\.com/tracks/([a-zA-Z0-9\-]+)',
    );
    final playlistUrlRegex = RegExp(
      r'https://rythmify\.com/playlists/([a-zA-Z0-9\-]+)',
    );

    final permalinkToEmbed = <String, SharedEmbed>{};
    for (final embed in _selectedEmbeds) {
      final url =
          'https://rythmify.com/${embed.embedType == 'track' ? 'tracks' : 'playlists'}/${embed.embedName}';
      permalinkToEmbed[url] = embed;
    }

    String remaining = text;

    while (remaining.isNotEmpty) {
      String? foundUrl;
      int foundIndex = remaining.length;
      String? extractedTrackId;
      String? extractedPlaylistId;

      for (final url in permalinkToEmbed.keys) {
        final idx = remaining.indexOf(url);
        if (idx != -1 && idx < foundIndex) {
          foundIndex = idx;
          foundUrl = url;
          final embed = permalinkToEmbed[url]!;
          extractedTrackId = embed.embedType == 'track' ? embed.embedId : null;
          extractedPlaylistId = embed.embedType != 'track'
              ? embed.embedId
              : null;
        }
      }

      final trackMatch = trackUrlRegex.firstMatch(remaining);
      if (trackMatch != null && trackMatch.start < foundIndex) {
        foundIndex = trackMatch.start;
        foundUrl = trackMatch.group(0);
        extractedTrackId = trackMatch.group(1);
        extractedPlaylistId = null;
      }

      final playlistMatch = playlistUrlRegex.firstMatch(remaining);
      if (playlistMatch != null && playlistMatch.start < foundIndex) {
        foundIndex = playlistMatch.start;
        foundUrl = playlistMatch.group(0);
        extractedTrackId = null;
        extractedPlaylistId = playlistMatch.group(1);
      }

      if (foundUrl != null) {
        final textBefore = remaining.substring(0, foundIndex).trim();
        if (textBefore.isNotEmpty) {
          await ref
              .read(sendMessageProvider.notifier)
              .sendMessage(conversationId: conversationId, body: textBefore);
        }

        await ref
            .read(sendMessageProvider.notifier)
            .sendMessage(
              conversationId: conversationId,
              trackId: extractedTrackId,
              playlistId: extractedPlaylistId,
            );

        remaining = remaining.substring(foundIndex + foundUrl.length).trim();
      } else {
        if (remaining.trim().isNotEmpty) {
          await ref
              .read(sendMessageProvider.notifier)
              .sendMessage(
                conversationId: conversationId,
                body: remaining.trim(),
              );
        }
        remaining = '';
      }
    }
  }

  Future<void> _sendInExistingConv() async {
    try {
      if (_selectedEmbeds.isEmpty && controller.text.trim().isEmpty) return;

      await _processAndSendMessages(
        widget.conv!.conversationId,
        controller.text,
      );

      if (mounted) {
        ref.invalidate(conversationProvider);
        ref.invalidate(messageProvider(widget.conv!.conversationId));
        controller.clear();
        setState(() => _selectedEmbeds.clear());
      }
    } catch (e) {
      print('❌ _sendInExistingConv error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send error: $e')),
      );
    }
  }

  Future<void> _sendInNewConv() async {
    try {
      if (_selectedEmbeds.isEmpty && controller.text.trim().isEmpty) return;

      Conversation? newConv = await ref
          .read(sendMessageProvider.notifier)
          .sendMessage(newParticipantId: widget.newParticipantId, body: null);

      if (newConv == null) return;

      _socket.joinConversation(newConv.conversationId);
      _socket.onMessageReceived((data) {
        if (mounted) {
          ref.invalidate(messageProvider(newConv.conversationId));
          ref.invalidate(conversationProvider);
        }
      });

      await _processAndSendMessages(newConv.conversationId, controller.text);

      if (mounted) {
        ref.invalidate(conversationProvider);
        controller.clear();
        setState(() => _selectedEmbeds.clear());

        context.go(
          '/home/inbox/chat/${newConv.conversationId}',
          extra: newConv,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message. Please try again.'),
        ),
      );
    }
  }
}
