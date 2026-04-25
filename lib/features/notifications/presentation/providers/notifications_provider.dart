import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/comments/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:rythmify/features/comments/presentation/providers/comment_di_providers.dart';
import 'package:rythmify/features/messaging/presentation/providers/socket_provider.dart';
import 'package:rythmify/features/notifications/domain/entities/notification_entity.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:rythmify/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:rythmify/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:rythmify/features/notifications/presentation/providers/repo_provider.dart';
import 'package:rythmify/features/profile/data/datasources/profile_remote_datasource_impl.dart';
import 'package:rythmify/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:rythmify/features/profile/domain/usecases/get_follow_user_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_unfollow_user_usecase.dart';

class NotificationsState {
  final List<NotificationEntity> items;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final int currentPage;
  final String? error;
  final Set<String> likedCommentIds;

  const NotificationsState({
    this.items = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasNext = false,
    this.currentPage = 0,
    this.error,
    this.likedCommentIds = const {},
  });

  NotificationsState copyWith({
    List<NotificationEntity>? items,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNext,
    int? currentPage,
    String? error,
    bool clearError = false,
    Set<String>? likedCommentIds,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNext: hasNext ?? this.hasNext,
      currentPage: currentPage ?? this.currentPage,
      error: clearError ? null : (error ?? this.error),
      likedCommentIds: likedCommentIds ?? this.likedCommentIds,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final GetNotificationsUsecase _getNotifications;
  final MarkNotificationAsReadUsecase _markRead;
  final GetFollowUserUseCase _follow;
  final GetUnfollowUserUseCase _unfollow;
  final ToggleCommentLikeUseCase _toggleCommentLike;

  NotificationsNotifier({
    required GetNotificationsUsecase getNotifications,
    required GetUnreadCountUsecase getUnreadCount,
    required MarkNotificationAsReadUsecase markAllRead,
    required GetFollowUserUseCase followUser,
    required GetUnfollowUserUseCase unfollowUser,
    required ToggleCommentLikeUseCase toggleCommentLike,
  })  : _getNotifications = getNotifications,
        _markRead = markAllRead,
        _follow = followUser,
        _unfollow = unfollowUser,
        _toggleCommentLike = toggleCommentLike,
        super(const NotificationsState());

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _getNotifications(page: 1);
      final unread = result.items.where((n) => !n.isRead).toList();

      state = state.copyWith(
        items: result.items,
        unreadCount: result.unreadCount,
        hasNext: result.hasNext,
        currentPage: 1,
        isLoading: false,
      );

      if (unread.isNotEmpty) {
        state = state.copyWith(unreadCount: 0);
        for (final n in unread) {
          _markRead(n.id).catchError((_) {});
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAll() async {
    while (state.hasNext) {
      await loadMore();
    }
  }

  Future<void> loadMore() async {
    if (!state.hasNext || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _getNotifications(page: nextPage);
      state = state.copyWith(
        items: [...state.items, ...result.items],
        hasNext: result.hasNext,
        currentPage: nextPage,
        isLoadingMore: false,
      );
      for (final n in result.items.where((n) => !n.isRead)) {
        _markRead(n.id).catchError((_) {});
      }
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> toggleFollow(
    String notificationId,
    String actorId,
    bool currentlyFollowing,
  ) async {
    state = state.copyWith(
      items: state.items
          .map((n) => n.id == notificationId
              ? n.copyWith(isActorFollowed: !currentlyFollowing)
              : n)
          .toList(),
    );
    final result = currentlyFollowing
        ? await _unfollow(userId: actorId)
        : await _follow(userId: actorId);
    result.fold(
      (_) {
        state = state.copyWith(
          items: state.items
              .map((n) => n.id == notificationId
                  ? n.copyWith(isActorFollowed: currentlyFollowing)
                  : n)
              .toList(),
        );
      },
      (_) {},
    );
  }

  Future<void> toggleCommentLike(String commentId) async {
    final isLiked = state.likedCommentIds.contains(commentId);
    final newSet = Set<String>.from(state.likedCommentIds);
    isLiked ? newSet.remove(commentId) : newSet.add(commentId);
    state = state.copyWith(likedCommentIds: newSet);
    try {
      await _toggleCommentLike(commentId, isCurrentlyLiked: isLiked);
    } catch (_) {
      final revertSet = Set<String>.from(state.likedCommentIds);
      isLiked ? revertSet.add(commentId) : revertSet.remove(commentId);
      state = state.copyWith(likedCommentIds: revertSet);
    }
  }

  void onSocketNotificationCreated() {
    state = state.copyWith(unreadCount: state.unreadCount + 1);
  }

  void onSocketNotificationRead() {
    if (state.unreadCount > 0) {
      state = state.copyWith(unreadCount: state.unreadCount - 1);
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  final repo = ref.read(repositoryprovider);
  final profileRepo = ProfileRepositoryImpl(
    remoteDatasource: ProfileRemoteDatasourceImpl(client: apiClient),
  );
  return NotificationsNotifier(
    getNotifications: GetNotificationsUsecase(repo),
    getUnreadCount: GetUnreadCountUsecase(repo),
    markAllRead: MarkNotificationAsReadUsecase(repo),
    followUser: GetFollowUserUseCase(profileRepo),
    unfollowUser: GetUnfollowUserUseCase(profileRepo),
    toggleCommentLike: ref.read(toggleCommentLikeProvider),
  );
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});

final notificationSocketProvider = Provider<void>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is! AuthAuthenticated) return;

  final socket = ref.watch(socketProvider);
  final notifier = ref.read(notificationsProvider.notifier);

  socket.onNotificationCreated((_) => notifier.onSocketNotificationCreated());
  socket.onNotificationRead((_) => notifier.onSocketNotificationRead());
});
