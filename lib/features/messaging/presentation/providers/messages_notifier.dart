import 'dart:math';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/features/messaging/domain/entities/message.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_messages_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

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

class MessagesNotifier extends StateNotifier<MessagesState> {
  final GetMessagesUsecase _usecase;
  final String _conversationId;
  static const int _limit = 100;
  int _oldestOffset = 0;

  MessagesNotifier({
    required MessagingRepository repo,
    required String conversationId,
  })  : _usecase = GetMessagesUsecase(repo: repo),
        _conversationId = conversationId,
        super(const MessagesState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = const MessagesState(isLoading: true);
    try {
      final (firstBatch, total) = await _usecase(_conversationId, offset: 0);

      if (total <= _limit) {
        _oldestOffset = 0;
        state = MessagesState(
          messages: firstBatch,
          isLoading: false,
          hasMore: false,
        );
      } else {
        final latestOffset = total - _limit;
        final (latestBatch, _) = await _usecase(_conversationId, offset: latestOffset);
        _oldestOffset = latestOffset;
        state = MessagesState(
          messages: latestBatch,
          isLoading: false,
          hasMore: latestOffset > 0,
        );
      }
    } catch (e) {
      state = MessagesState(isLoading: false, error: e.toString(), hasMore: false);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || _oldestOffset <= 0) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final olderOffset = max(0, _oldestOffset - _limit);
      final (older, _) = await _usecase(_conversationId, offset: olderOffset);
      _oldestOffset = olderOffset;
      state = state.copyWith(
        messages: [...older, ...state.messages],
        isLoadingMore: false,
        hasMore: olderOffset > 0,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() => loadInitial();
}

final messagesNotifierProvider =
    StateNotifierProvider.family<MessagesNotifier, MessagesState, String>(
  (ref, conversationId) {
    return MessagesNotifier(
      repo: ref.read(repositoryprovider),
      conversationId: conversationId,
    );
  },
);
