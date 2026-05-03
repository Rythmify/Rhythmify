import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/data/datasources/data_sources_sockets.dart';
import 'package:rythmify/features/messaging/data/models/message_model.dart';
import 'package:rythmify/features/messaging/domain/entities/conversation.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/presentation/providers/current_user_id_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/is_blocked_by_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/mark_as_read_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/messages_notifier.dart';
import 'package:rythmify/features/messaging/presentation/providers/send_message_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/socket_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/unread_messages_provider.dart';
import 'package:rythmify/features/messaging/presentation/providers/conversations_provider.dart';
import 'package:rythmify/features/messaging/presentation/widgets/blocked_by_widget.dart';
import 'package:rythmify/features/messaging/presentation/widgets/blocked_user_widget.dart';
import 'package:rythmify/features/messaging/presentation/widgets/message_bubble.dart';
import 'package:rythmify/features/messaging/presentation/widgets/message_input_bubble.dart';
import 'package:rythmify/features/messaging/presentation/widgets/pop_up_menu_widget.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';
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
  final String? convId;

  const ChatScreen({
    super.key,
    this.conv,
    this.newParticipantName,
    this.newParticipantId,
    this.convId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController controller;
  late final ScrollController _scrollController;
  final List<SharedEmbed> _selectedEmbeds = [];
  final Map<String, SharedEmbed> _embedCache = {};
  late DataSourcesSockets _socket;
  Timer? _urlDetectionTimer;
  Timer? _blockPollTimer;
  Conversation? _resolvedConv;
  Conversation? get _effectiveConv => widget.conv ?? _resolvedConv;

  // false while the async conv-existence check is running, true once done.
  bool _newConvCheckDone = true;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.addListener(_onTextChanged);
    _scrollController = ScrollController();
    _socket = ref.read(socketProvider);
    if (widget.conv != null) {
      _scrollController.addListener(_onScroll);
      Future.microtask(() {
        if (!mounted) return;
        ref.invalidate(conversationProvider);
        ref.invalidate(messagesNotifierProvider(widget.conv!.conversationId));
        if (widget.conv!.participantId.isNotEmpty) {
          ref.invalidate(isBlockedProvider(widget.conv!.participantId));
          ref.invalidate(isBlockedByProvider(widget.conv!.participantId));
        }
        _socket.joinConversation(widget.conv!.conversationId);
        _setupSocketListeners(widget.conv!.conversationId);
        _socket.setOnReconnectedToRoom(() {
          if (mounted) _setupSocketListeners(widget.conv!.conversationId);
        });
        _blockPollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          if (mounted &&
              widget.conv != null &&
              widget.conv!.participantId.isNotEmpty) {
            ref.invalidate(isBlockedByProvider(widget.conv!.participantId));
          }
        });
      });
    } else if (widget.convId != null) {
      Future.microtask(() async {
        if (!mounted) return;
        final convs = await ref.read(conversationProvider.future);
        final found = convs.cast<Conversation?>().firstWhere(
          (c) => c?.conversationId == widget.convId,
          orElse: () => null,
        );
        if (!mounted || found == null) return;
        setState(() => _resolvedConv = found);
        if (!mounted) return;
        _scrollController.addListener(_onScroll);
        ref.invalidate(conversationProvider);
        ref.invalidate(messagesNotifierProvider(found.conversationId));
        if (found.participantId.isNotEmpty) {
          ref.invalidate(isBlockedProvider(found.participantId));
          ref.invalidate(isBlockedByProvider(found.participantId));
        }
        _socket.joinConversation(found.conversationId);
        _setupSocketListeners(found.conversationId);
        _socket.setOnReconnectedToRoom(() {
          if (mounted) _setupSocketListeners(found.conversationId);
        });
        _blockPollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
          if (mounted && found.participantId.isNotEmpty) {
            ref.invalidate(isBlockedByProvider(found.participantId));
          }
        });
      });
    } else if (widget.newParticipantId != null) {
      _newConvCheckDone = false;
      Future.microtask(() async {
        if (!mounted) return;
        try {
          final repo = ref.read(repositoryprovider);
          final convs = await repo.getConversations();
          if (!mounted) return;
          final found = convs.cast<Conversation?>().firstWhere(
            (c) => c?.participantId == widget.newParticipantId,
            orElse: () => null,
          );
          if (!mounted) return;
          if (found == null) {
            setState(() => _newConvCheckDone = true);
            return;
          }
          // Existing conv found — set up exactly like the convId branch.
          setState(() {
            _resolvedConv = found;
            _newConvCheckDone = true;
          });
          if (!mounted) return;
          _scrollController.addListener(_onScroll);
          ref.invalidate(messagesNotifierProvider(found.conversationId));
          if (found.participantId.isNotEmpty) {
            ref.invalidate(isBlockedProvider(found.participantId));
            ref.invalidate(isBlockedByProvider(found.participantId));
          }
          _socket.joinConversation(found.conversationId);
          _setupSocketListeners(found.conversationId);
          _socket.setOnReconnectedToRoom(() {
            if (mounted) _setupSocketListeners(found.conversationId);
          });
          _blockPollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
            if (mounted && found.participantId.isNotEmpty) {
              ref.invalidate(isBlockedByProvider(found.participantId));
            }
          });
        } catch (_) {
          if (mounted) setState(() => _newConvCheckDone = true);
        }
      });
    }
  }

  void _onScroll() {
    if (_effectiveConv == null) return;
    final pos = _scrollController.position;
    // reversed list: maxScrollExtent = visual top (oldest messages)
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref
          .read(
            messagesNotifierProvider(_effectiveConv!.conversationId).notifier,
          )
          .loadMore();
    }
  }

  void _setupSocketListeners(String conversationId) {
    _socket.onUserBlocked((_) {
      if (mounted && _effectiveConv?.participantId != null) {
        ref.invalidate(isBlockedByProvider(_effectiveConv!.participantId));
        ref.invalidate(conversationProvider);
      }
    });
    _socket.onMessageReceived((data) {
      if (mounted) {
        final message = MessageModel.fromJson(
          data['message'] as Map<String, dynamic>,
        );
        ref
            .read(messagesNotifierProvider(conversationId).notifier)
            .appendMessage(message);
        ref.invalidate(conversationProvider);
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        _socket.markRead(conversationId, message.messageId, true, 0);
      }
    });
    _socket.onMessageReadUpdated((data) {
      if (mounted) {
        final messageId = data['messageId'] as String?;
        if (messageId != null) {
          ref
              .read(messagesNotifierProvider(conversationId).notifier)
              .updateMessageRead(messageId);
        }
        ref.invalidate(conversationProvider);
      }
    });
  }

  @override
  void dispose() {
    _urlDetectionTimer?.cancel();
    final conv = _effectiveConv;
    if (conv != null) {
      _socket.leaveConversation(conv.conversationId);
    }
    _socket.clearConversationListeners();
    _scrollController.dispose();
    controller.dispose();
    _blockPollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(currentUserIdProvider);

    final msgState = _effectiveConv != null
        ? ref.watch(messagesNotifierProvider(_effectiveConv!.conversationId))
        : null;

    final unreadMsgProvider = _effectiveConv != null
        ? ref.watch(unreadProvider(_effectiveConv!.conversationId))
        : null;

    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    final participantId =
        _effectiveConv?.participantId ?? widget.newParticipantId;

    final isBlockedAsync = participantId != null && participantId.isNotEmpty
        ? ref.watch(isBlockedProvider(participantId))
        : const AsyncValue<bool>.data(false);
    final bool isBlocked = isBlockedAsync.value ?? false;

    final isBlockedByAsync = participantId != null && participantId.isNotEmpty
        ? ref.watch(isBlockedByProvider(participantId))
        : const AsyncValue<bool>.data(false);
    final bool isBlockedBy = isBlockedByAsync.value ?? false;

    return Scaffold(
      key: const Key('chat_screen_scaffold'),
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        key: const Key('chat_screen_app_bar'),
        title: GestureDetector(
          onTap: () {
            final id = _effectiveConv?.participantId ?? widget.newParticipantId;
            if (id != null) context.push('/home/profile/$id');
          },
          child: Text(
            _effectiveConv?.participantName ??
                widget.newParticipantName ??
                'Chat',
            key: const Key('chat_participant_name_text'),
          ),
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
                    onBlocked: _effectiveConv != null
                        ? () => _socket.leaveConversation(
                            _effectiveConv!.conversationId,
                          )
                        : null,
                  ),
                  backgroundColor: const Color(0xFF121212),
                );
              },
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
        ],
      ),
      body:
          (widget.convId != null && _resolvedConv == null) || !_newConvCheckDone
          ? const Center(child: CircularProgressIndicator())
          : _effectiveConv == null
          ? _blanckChatPage(isBlocked: isBlocked, isBlockedBy: isBlockedBy)
          : msgState == null
          ? const Center(child: CircularProgressIndicator())
          : msgState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : msgState.error != null
          ? Center(
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
                      if (mounted && _effectiveConv != null) {
                        ref
                            .read(
                              messagesNotifierProvider(
                                _effectiveConv!.conversationId,
                              ).notifier,
                            )
                            .refresh();
                      }
                    },
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            )
          : Builder(
              builder: (context) {
                unreadMsgProvider?.whenData((unreads) {
                  if (unreads.isNotEmpty) {
                    Future.microtask(() async {
                      if (!mounted) return;
                      final latestUnreads = await ref.read(
                        unreadProvider(_effectiveConv!.conversationId).future,
                      );
                      for (final unread in latestUnreads) {
                        if (!mounted) return;
                        await ref
                            .read(markAsRead.notifier)
                            .markRead(
                              msgId: unread.messageId,
                              convId: unread.conversationId,
                            );
                        await Future.delayed(const Duration(microseconds: 500));
                        if (!mounted) return;
                        ref.invalidate(conversationProvider);
                      }
                    });
                  }
                });
                final groups = _groupMessages(msgState.messages);
                return Column(
                  children: [
                    if (msgState.isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 12,
                          bottom: 150,
                        ),
                        itemCount: groups.length,
                        itemBuilder: (context, groupIndex) {
                          final group = groups[groups.length - 1 - groupIndex];
                          final isMe =
                              group.isNotEmpty && group.first.senderId == myId;

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
                                        ? _effectiveConv?.participantAvatar
                                        : null,
                                    showAvatar: index == group.length - 1,
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
                            key: const Key('chat_screen_blocked_user_widget'),
                            participantId: participantId,
                            onUnblocked: _effectiveConv != null
                                ? () {
                                    _socket.joinConversation(
                                      _effectiveConv!.conversationId,
                                    );
                                    _setupSocketListeners(
                                      _effectiveConv!.conversationId,
                                    );
                                  }
                                : null,
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
                                    final e = _selectedEmbeds[index];
                                    controller.text = controller.text
                                        .replaceAll(_permalinkFor(e), '')
                                        .replaceAll(_idUrlFor(e), '')
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
                                        if (_effectiveConv == null) return;
                                        final embeds = await context
                                            .push<List<SharedEmbed>>(
                                              '/home/inbox/chat/${_effectiveConv!.conversationId}/likes-playlists',
                                              extra: List<SharedEmbed>.from(
                                                _selectedEmbeds,
                                              ),
                                            );
                                        if (embeds != null) {
                                          setState(() {
                                            _reconcileEmbeds(embeds);
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
                                    ValueListenableBuilder<TextEditingValue>(
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
            ),
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
                      final e = _selectedEmbeds[index];
                      controller.text = controller.text
                          .replaceAll(_permalinkFor(e), '')
                          .replaceAll(_idUrlFor(e), '')
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
                                  extra: List<SharedEmbed>.from(
                                    _selectedEmbeds,
                                  ),
                                );
                            if (embeds != null) {
                              setState(() {
                                _reconcileEmbeds(embeds);
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
                            onSubmitted: (_) async {
                              if (controller.text.trim().isNotEmpty) {
                                if (_effectiveConv != null) {
                                  await _sendInExistingConv();
                                } else if (_newConvCheckDone) {
                                  await _sendInNewConv();
                                }
                              }
                            },
                          ),
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: controller,
                          builder: (context, value, child) {
                            if (value.text.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            if (!_newConvCheckDone) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              );
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
      // final closeInTime =
      //     curr.createdAt.difference(prev.createdAt).inMilliseconds.abs() <= 100;
      final hasEmbed = curr.embedId != null || prev.embedId != null;
      final timeDiff = curr.createdAt
          .difference(prev.createdAt)
          .inMilliseconds
          .abs();
      final closeInTime = hasEmbed && timeDiff <= 1000;

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

    if (duration.isNegative || duration.inSeconds < 1) return '0 seconds ago';

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

  // ─── URL → embed preview ──────────────────────────────────────────────────
  // Detects Rythmify URLs typed/pasted into the text field and fetches their
  // embed details to populate the preview widget. Text is NOT modified here —
  // the URLs stay in the controller so they activate the send button and are
  // parsed by _processAndSendMessages at send time.

  static final _trackUrlRegex = RegExp(
    r'https://rythmify\.com/tracks/([a-zA-Z0-9_\-]+)',
  );
  static final _playlistUrlRegex = RegExp(
    r'https://rythmify\.com/playlists/([a-zA-Z0-9_\-]+)',
  );

  void _onTextChanged() {
    _urlDetectionTimer?.cancel();
    _urlDetectionTimer = Timer(
      const Duration(milliseconds: 400),
      _checkForCopyLinkEmbeds,
    );
  }

  Future<void> _checkForCopyLinkEmbeds() async {
    if (!mounted) return;
    final text = controller.text;
    final repo = ref.read(repositoryprovider);

    // Remove preview cards whose URL is no longer present (or has been edited).
    final orphaned = _selectedEmbeds
        .where(
          (e) =>
              !text.contains(_permalinkFor(e)) && !text.contains(_idUrlFor(e)),
        )
        .toList();
    if (orphaned.isNotEmpty) {
      setState(() => _selectedEmbeds.removeWhere(orphaned.contains));
    }

    // Restore any previously-seen embed whose URL reappeared in text.
    // Uses full URL text match so multi-word embed names (which the regex
    // cannot fully capture due to spaces) are correctly restored from cache.
    final seenIds = <String>{};
    for (final embed in _embedCache.values) {
      if (!seenIds.add(embed.embedId)) continue;
      if (_selectedEmbeds.any((e) => e.embedId == embed.embedId)) continue;
      if (text.contains(_permalinkFor(embed)) ||
          text.contains(_idUrlFor(embed))) {
        if (mounted) setState(() => _selectedEmbeds.add(embed));
      }
    }

    // Detect URLs for embeds not yet in the cache (first paste / never seen before).
    final pending = <({String segment, String type})>[];
    for (final m in _trackUrlRegex.allMatches(text)) {
      final seg = m.group(1)!;
      if (_selectedEmbeds.any((e) => e.embedId == seg || e.embedName == seg)) {
        continue;
      }
      if (_embedCache.containsKey(seg)) continue;
      pending.add((segment: seg, type: 'track'));
    }

    for (final m in _playlistUrlRegex.allMatches(text)) {
      final seg = m.group(1)!;
      if (_selectedEmbeds.any((e) => e.embedId == seg || e.embedName == seg)) {
        continue;
      }
      if (_embedCache.containsKey(seg)) continue;
      pending.add((segment: seg, type: 'playlist'));
    }

    for (final (:segment, :type) in pending) {
      try {
        final embed = type == 'track'
            ? await repo.getTrack(segment)
            : await repo.getPlaylist(segment, 'playlist');
        if (mounted &&
            !_selectedEmbeds.any((e) => e.embedId == embed.embedId)) {
          _embedCache[embed.embedId] = embed;
          _embedCache[embed.embedName] = embed;
          setState(() => _selectedEmbeds.add(embed));
        }
      } catch (_) {
        // Not a valid resource ID — name slug or bad URL; leave text as-is.
      }
    }
  }

  // ─── Library picker reconciliation ────────────────────────────────────────

  String _permalinkFor(SharedEmbed e) =>
      'https://rythmify.com/${e.embedType == 'track' ? 'tracks' : 'playlists'}/${e.embedName}';

  String _idUrlFor(SharedEmbed e) =>
      'https://rythmify.com/${e.embedType == 'track' ? 'tracks' : 'playlists'}/${e.embedId}';

  void _reconcileEmbeds(List<SharedEmbed> returned) {
    for (final e in returned) {
      _embedCache[e.embedId] = e;
      _embedCache[e.embedName] = e;
    }

    final currentIds = {for (final e in _selectedEmbeds) e.embedId};
    final returnedIds = {for (final e in returned) e.embedId};

    // Remove deselected embeds — try both name-based and ID-based URLs.
    for (final removed in _selectedEmbeds.where(
      (e) => !returnedIds.contains(e.embedId),
    )) {
      controller.text = controller.text
          .replaceAll(_permalinkFor(removed), '')
          .replaceAll(_idUrlFor(removed), '')
          .trim();
    }

    // Add newly selected embeds as name-based permalinks.
    final newEmbeds = returned
        .where((e) => !currentIds.contains(e.embedId))
        .toList();
    if (newEmbeds.isNotEmpty) {
      final newLinks = newEmbeds.map(_permalinkFor).join('\n');
      final existing = controller.text;
      controller.text = existing.isEmpty ? newLinks : '$existing\n$newLinks';
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }

    _selectedEmbeds
      ..clear()
      ..addAll(returned);
  }

  // ─── Send ─────────────────────────────────────────────────────────────────

  Future<Conversation?> _processAndSendMessages(
    String? conversationId,
    String text, {
    String? newParticipantId,
  }) async {
    final permalinkToEmbed = <String, SharedEmbed>{
      for (final e in _selectedEmbeds) _permalinkFor(e): e,
    };

    String remaining = text;
    String? resolvedConvId = conversationId;
    Conversation? createdConv;

    Future<void> doSend({
      String? body,
      String? embedId,
      String? embedType,
    }) async {
      if (resolvedConvId != null) {
        await ref
            .read(sendMessageProvider.notifier)
            .sendMessage(
              conversationId: resolvedConvId,
              body: body,
              embedId: embedId,
              embedType: embedType,
            );
      } else {
        final conv = await ref
            .read(sendMessageProvider.notifier)
            .sendMessage(
              newParticipantId: newParticipantId,
              body: body,
              embedId: embedId,
              embedType: embedType,
            );
        if (conv != null) {
          createdConv = conv;
          resolvedConvId = conv.conversationId;
        }
      }
    }

    while (remaining.isNotEmpty) {
      String? foundUrl;
      int foundIndex = remaining.length;
      String? extractedEmbedId;
      String? extractedEmbedType;

      for (final url in permalinkToEmbed.keys) {
        final idx = remaining.indexOf(url);
        if (idx != -1 && idx < foundIndex) {
          foundIndex = idx;
          foundUrl = url;
          extractedEmbedId = permalinkToEmbed[url]!.embedId;
          extractedEmbedType = permalinkToEmbed[url]!.embedType;
        }
      }

      final trackMatch = _trackUrlRegex.firstMatch(remaining);
      if (trackMatch != null && trackMatch.start < foundIndex) {
        final seg = trackMatch.group(1)!;
        if (_selectedEmbeds.any((e) => e.embedId == seg)) {
          foundIndex = trackMatch.start;
          foundUrl = trackMatch.group(0);
          extractedEmbedId = seg;
          extractedEmbedType = 'track';
        }
      }

      final playlistMatch = _playlistUrlRegex.firstMatch(remaining);
      if (playlistMatch != null && playlistMatch.start < foundIndex) {
        final seg = playlistMatch.group(1)!;
        if (_selectedEmbeds.any((e) => e.embedId == seg)) {
          foundIndex = playlistMatch.start;
          foundUrl = playlistMatch.group(0);
          extractedEmbedId = seg;
          extractedEmbedType = 'playlist';
        }
      }

      if (foundUrl != null) {
        final textBefore = remaining.substring(0, foundIndex).trim();
        if (textBefore.isNotEmpty) {
          await doSend(body: textBefore);
        }
        await doSend(embedId: extractedEmbedId, embedType: extractedEmbedType);
        remaining = remaining.substring(foundIndex + foundUrl.length).trim();
      } else {
        if (remaining.isNotEmpty) {
          await doSend(body: remaining);
        }
        remaining = '';
      }
    }

    return createdConv;
  }

  String _messageFor403(DioException e) {
    final code = (e.response?.data as Map?)?['error']?['code'] as String?;
    return switch (code) {
      'MESSAGES_DISABLED' => "This user doesn't accept messages from anyone",
      'MESSAGES_FOLLOWERS_ONLY' =>
        "This user only accepts messages from people they follow",
      'MESSAGES_BLOCKED' => "You can't send messages to this user",
      _ => 'You can no longer send messages to this user',
    };
  }

  Future<void> _sendInExistingConv() async {
    try {
      if (_selectedEmbeds.isEmpty && controller.text.trim().isEmpty) return;
      await _processAndSendMessages(
        _effectiveConv!.conversationId,
        controller.text,
      );
      if (mounted) {
        controller.clear();
        setState(() => _selectedEmbeds.clear());
      }
    } on DioException catch (e) {
      if (!mounted) return;
      if (e.response?.statusCode == 403) {
        final participantId = _effectiveConv?.participantId;
        if (participantId != null && participantId.isNotEmpty) {
          ref.invalidate(isBlockedByProvider(participantId));
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.response?.statusCode == 403
                ? _messageFor403(e)
                : 'Failed to send message. Please try again.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message. Please try again.'),
        ),
      );
    }
  }

  Future<void> _sendInNewConv() async {
    try {
      if (_selectedEmbeds.isEmpty && controller.text.trim().isEmpty) return;

      // If an existing conversation was found during the pre-check, send there.
      if (_resolvedConv != null) {
        await _processAndSendMessages(
          _resolvedConv!.conversationId,
          controller.text,
        );
        if (!mounted) return;
        ref.invalidate(conversationProvider);
        controller.clear();
        setState(() => _selectedEmbeds.clear());
        context.go(
          '/home/inbox/chat/${_resolvedConv!.conversationId}',
          extra: _resolvedConv,
        );
        return;
      }

      final newConv = await _processAndSendMessages(
        null,
        controller.text,
        newParticipantId: widget.newParticipantId!,
      );

      if (!mounted || newConv == null) return;

      final conv =
          newConv.participantName == 'Unknown' &&
              widget.newParticipantName != null
          ? newConv.copyWith(participantName: widget.newParticipantName)
          : newConv;

      ref.invalidate(conversationProvider);
      controller.clear();
      setState(() => _selectedEmbeds.clear());
      context.go('/home/inbox/chat/${conv.conversationId}', extra: conv);
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.response?.statusCode == 403
                ? _messageFor403(e)
                : 'Failed to send message. Please try again.',
          ),
        ),
      );
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
