import 'dart:async';

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
  late final ScrollController _scrollController;
  final List<SharedEmbed> _selectedEmbeds = [];
  final Map<String, SharedEmbed> _embedCache = {};
  late DataSourcesSockets _socket;
  Timer? _urlDetectionTimer;

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
      });
    }
  }

  void _onScroll() {
    if (widget.conv == null) return;
    final pos = _scrollController.position;
    // reversed list: maxScrollExtent = visual top (oldest messages)
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref
          .read(messagesNotifierProvider(widget.conv!.conversationId).notifier)
          .loadMore();
    }
  }

  void _setupSocketListeners(String conversationId) {
    _socket.onMessageReceived((data) {
      print('🔥 onMessageReceived fired: $data');
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
    if (widget.conv != null) {
      _socket.leaveConversation(widget.conv!.conversationId);
    }
    _socket.clearConversationListeners();
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = ref.watch(currentUserIdProvider);

    final msgState = widget.conv != null
        ? ref.watch(messagesNotifierProvider(widget.conv!.conversationId))
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
                      if (mounted && widget.conv != null) {
                        ref
                            .read(
                              messagesNotifierProvider(
                                widget.conv!.conversationId,
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
                            key: const Key('chat_screen_blocked_user_widget'),
                            participantId: participantId,
                            onUnblocked: widget.conv != null
                                ? () {
                                    _socket.joinConversation(
                                      widget.conv!.conversationId,
                                    );
                                    _setupSocketListeners(
                                      widget.conv!.conversationId,
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
                                        if (widget.conv == null) return;
                                        final embeds = await context
                                            .push<List<SharedEmbed>>(
                                              '/home/inbox/chat/${widget.conv!.conversationId}/likes-playlists',
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
      if (_selectedEmbeds.any((e) => e.embedId == seg || e.embedName == seg))
        continue;
      if (_embedCache.containsKey(seg)) continue;
      pending.add((segment: seg, type: 'track'));
    }
    for (final m in _playlistUrlRegex.allMatches(text)) {
      final seg = m.group(1)!;
      if (_selectedEmbeds.any((e) => e.embedId == seg || e.embedName == seg))
        continue;
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

  Future<void> _processAndSendMessages(
    String conversationId,
    String text,
  ) async {
    // Build a name-URL → embed map so name-based permalinks resolve to the
    // actual embedId (which may differ from the embed name).
    final permalinkToEmbed = <String, SharedEmbed>{
      for (final e in _selectedEmbeds) _permalinkFor(e): e,
    };

    String remaining = text;

    while (remaining.isNotEmpty) {
      String? foundUrl;
      int foundIndex = remaining.length;
      String? extractedEmbedId;
      String? extractedEmbedType;

      // 1. Name-based permalinks (library selections) — highest priority.
      for (final url in permalinkToEmbed.keys) {
        final idx = remaining.indexOf(url);
        if (idx != -1 && idx < foundIndex) {
          foundIndex = idx;
          foundUrl = url;
          extractedEmbedId = permalinkToEmbed[url]!.embedId;
          extractedEmbedType = permalinkToEmbed[url]!.embedType;
        }
      }

      // 2. UUID-based copy links (tracks) — only if the listener already
      //    confirmed this embed is valid (i.e. it's in _selectedEmbeds).
      //    Broken/edited URLs won't be in _selectedEmbeds and fall through
      //    to plain-text sending.
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

      // 3. UUID-based copy links (playlists) — same guard.
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
          await ref
              .read(sendMessageProvider.notifier)
              .sendMessage(conversationId: conversationId, body: textBefore);
        }
        await ref
            .read(sendMessageProvider.notifier)
            .sendMessage(
              conversationId: conversationId,
              embedId: extractedEmbedId,
              embedType: extractedEmbedType,
            );
        remaining = remaining.substring(foundIndex + foundUrl.length).trim();
      } else {
        if (remaining.isNotEmpty) {
          await ref
              .read(sendMessageProvider.notifier)
              .sendMessage(conversationId: conversationId, body: remaining);
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
        controller.clear();
        setState(() => _selectedEmbeds.clear());
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Send error: $e')));
    }
  }

  Future<void> _sendInNewConv() async {
    try {
      if (_selectedEmbeds.isEmpty && controller.text.trim().isEmpty) return;

      final nConv = await ref
          .read(sendMessageProvider.notifier)
          .ensureConversation(widget.newParticipantId!);

      final newConv =
          nConv.participantName == 'Unknown' &&
              widget.newParticipantName != null
          ? nConv.copyWith(participantName: widget.newParticipantName)
          : nConv;

      _socket.joinConversation(newConv.conversationId);
      _socket.onMessageReceived((data) {
        if (mounted) {
          ref
              .read(messagesNotifierProvider(newConv.conversationId).notifier)
              .appendMessage(
                MessageModel.fromJson(data['message'] as Map<String, dynamic>),
              );
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
