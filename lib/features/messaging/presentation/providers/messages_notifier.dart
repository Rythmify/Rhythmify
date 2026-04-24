import 'dart:math';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_messages_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// Immutable state for the paginated message list in a conversation.
///
/// - [messages] holds the accumulated list of [Message]s ordered oldest → newest.
/// - [isLoading] is true during the initial fetch.
/// - [isLoadingMore] is true while fetching an older page (scroll-up pagination).
/// - [hasMore] indicates whether older messages exist that have not been loaded yet.
/// - [error] holds the error string if the last fetch failed.
class MessagesState {
  final List<Message> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const MessagesState({
    this.messages = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.error,
  });

  /// Returns a copy of this state with the specified fields replaced.
  MessagesState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Notifier that manages offset-based pagination for a single conversation's messages.
///
/// On creation, [loadInitial] is called automatically:
/// 1. Fetches offset=0 to discover [total].
/// 2. If [total] > [_limit], fetches the last page (offset = total − limit)
///    so the user always sees the **latest** messages first.
///
/// [loadMore] is triggered when the user scrolls to the top of the chat list,
/// fetching the next older page and prepending it to [MessagesState.messages].
///
/// [refresh] re-runs [loadInitial], resetting pagination back to the latest page.
///
/// Depends on [GetMessagesUsecase] and [repositoryprovider].
class MessagesNotifier extends StateNotifier<MessagesState> {
  final GetMessagesUsecase _usecase;
  final String _conversationId;
  int _total=0;

  /// Maximum number of messages fetched per request (matches server-side limit).
  static const int _limit = 100;

  /// Offset of the oldest page currently loaded. Used to calculate the next
  /// older page when [loadMore] is called.
  int _oldestOffset = 0;

  MessagesNotifier({
    required MessagingRepository repo,
    required String conversationId,
  }) : _usecase = GetMessagesUsecase(repo: repo),
       _conversationId = conversationId,
       super(const MessagesState()) {
    loadInitial();
  }

  /// Fetches the latest page of messages for the conversation.
  ///
  /// First performs a discovery fetch (offset=0) to obtain [total].
  /// If [total] exceeds [_limit], a second fetch loads the tail page
  /// so the chat opens showing the most recent messages.
  Future<void> loadInitial() async {
    if (!mounted) return;
    state = const MessagesState(isLoading: true);
    try {
      final (firstBatch, total) = await _usecase(_conversationId, offset: 0);
      if (!mounted) return;

      if (total <= _limit) {
        _oldestOffset = 0;
        state = MessagesState(
          messages: firstBatch,
          isLoading: false,
          hasMore: false,
        );
      } else {
        final latestOffset = total - _limit;
        final (latestBatch, _) = await _usecase(
          _conversationId,
          offset: latestOffset,
        );
        if (!mounted) return;
        _oldestOffset = latestOffset;
        state = MessagesState(
          messages: latestBatch,
          isLoading: false,
          hasMore: latestOffset > 0,
        );
      }
      _total=total;
    } catch (e) {
      if (!mounted) return;
      state = MessagesState(
        isLoading: false,
        error: e.toString(),
        hasMore: false,
      );
    }
  }

  /// Loads the next older page of messages and prepends them to the current list.
  ///
  /// No-op if [MessagesState.isLoadingMore] is true, [MessagesState.hasMore] is
  /// false, or [_oldestOffset] is already at 0.
  Future<void> loadMore() async {
    if (!mounted ||
        state.isLoadingMore ||
        !state.hasMore ||
        _oldestOffset <= 0) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    try {
      final olderOffset = max(0, _oldestOffset - _limit);
      final (older, _) = await _usecase(_conversationId, offset: olderOffset);
      if (!mounted) return;
      _oldestOffset = olderOffset;
      state = state.copyWith(
        messages: [...older, ...state.messages],
        isLoadingMore: false,
        hasMore: olderOffset > 0,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Re-fetches from the latest page, resetting all pagination state.
  ///
  /// Called by socket listeners on new message or read-status updates.
  Future<void> refresh() => loadInitial();

  void appendMessage(Message message){
    _total++;
  state=state.copyWith(messages:[...state.messages,message]);
  }

  void updateMessageRead(String messageId){
    state=state.copyWith(
      messages: state.messages
                     .map((m)=> m.messageId==messageId?m.copyWith(isRead: true):m)
                     .toList(),
    );
  }
}

/// Provider for [MessagesNotifier], scoped per [conversationId].
///
/// Depends on [repositoryprovider].
final messagesNotifierProvider =
    StateNotifierProvider.family<MessagesNotifier, MessagesState, String>((
      ref,
      conversationId,
    ) {
      return MessagesNotifier(
        repo: ref.read(repositoryprovider),
        conversationId: conversationId,
      );
    });

