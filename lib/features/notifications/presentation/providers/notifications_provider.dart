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
import 'package:rythmify/features/notifications/presentation/providers/follow_state_provider.dart';
import 'package:rythmify/features/notifications/presentation/providers/repo_provider.dart';
import 'package:rythmify/features/profile/data/datasources/profile_remote_datasource_impl.dart';
import 'package:rythmify/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:rythmify/features/profile/domain/usecases/get_follow_user_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_unfollow_user_usecase.dart';

/// Immutable snapshot of the notifications screen state.
class NotificationsState {
  /// All loaded notification items across all fetched pages.
  final List<NotificationEntity> items;

  /// Number of unread notifications. Reset to 0 after the first fetch marks them all read.
  final int unreadCount;

  /// True while the initial page 1 load is in progress.
  final bool isLoading;

  /// True while a subsequent page is being fetched.
  final bool isLoadingMore;

  /// Whether more pages are available beyond [currentPage].
  final bool hasNext;

  final int currentPage;

  /// Non-null when a fetch error occurred and no items are loaded.
  final String? error;

  /// IDs of comments the user has liked, tracked locally for optimistic UI.
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

/// Manages the full lifecycle of the notifications list.
///
/// Responsibilities:
/// - Paginated fetching ([fetch], [loadMore], [loadAll])
/// - Fire-and-forget mark-as-read for every unread notification that arrives
/// - Seeding [FollowStateNotifier] with live follow status for follow-type notifications
/// - Optimistic follow/unfollow with revert on failure
/// - Optimistic comment like/unlike with revert on failure
/// - Incrementing / decrementing [unreadCount] on socket events
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final GetNotificationsUsecase _getNotifications;
  final MarkNotificationAsReadUsecase _markRead;
  final GetFollowUserUseCase _follow;
  final GetUnfollowUserUseCase _unfollow;
  final ToggleCommentLikeUseCase _toggleCommentLike;
  final FollowStateNotifier _followState;
  String? _activeType;

  NotificationsNotifier({
    required GetNotificationsUsecase getNotifications,
    required GetUnreadCountUsecase getUnreadCount,
    required MarkNotificationAsReadUsecase markAllRead,
    required GetFollowUserUseCase followUser,
    required GetUnfollowUserUseCase unfollowUser,
    required ToggleCommentLikeUseCase toggleCommentLike,
    required FollowStateNotifier followState,
  }) : _getNotifications = getNotifications,
       _markRead = markAllRead,
       _follow = followUser,
       _unfollow = unfollowUser,
       _toggleCommentLike = toggleCommentLike,
       _followState = followState,
       super(const NotificationsState());

  /// Loads page 1, replaces any existing items, and fires mark-read for all
  /// unread items. Also seeds [FollowStateNotifier] for follow-type actors.
  Future<void> fetch({String? type}) async {
    _activeType = type;
    state = state.copyWith(isLoading: true, clearError: true, items: []);
    try {
      final result = await _getNotifications(page: 1, type: _activeType);
      final unread = result.items.where((n) => !n.isRead).toList();

      state = state.copyWith(
        items: result.items,
        unreadCount: result.unreadCount,
        hasNext: result.hasNext,
        currentPage: 1,
        isLoading: false,
      );

      for (final n in result.items.where(
        (n) => n.type == NotificationType.follow,
      )) {
        _followState.fetchFollowState(n.actorId);
      }

      // if (unread.isNotEmpty) {
      //   state = state.copyWith(unreadCount: 0);
      //   for (final n in unread) {
      //     _markRead(n.id).catchError((_) {});
      //   }
      // }

      for (final n in unread) {
        _markRead(n.id).catchError((_) {});
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Keeps loading pages until [hasNext] is false.
  /// Used when a filter is applied that requires the full list client-side.
  // Future<void> loadAll() async {
  //   while (state.hasNext) {
  //     final prevPage=state.currentPage;
  //     await loadMore();
  //     if(state.currentPage==prevPage) break;
  //   }
  // }

  /// Appends the next page to [items]. Marks new unread items as read
  /// and seeds follow states for any follow-type actors in the page.
  Future<void> loadMore() async {
    if (!state.hasNext || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await _getNotifications(page: nextPage, type: _activeType);
      state = state.copyWith(
        items: [...state.items, ...result.items],
        hasNext: result.hasNext,
        currentPage: nextPage,
        isLoadingMore: false,
      );
      for (final n in result.items.where((n) => !n.isRead)) {
        _markRead(n.id).catchError((_) {});
      }
      for (final n in result.items.where(
        (n) => n.type == NotificationType.follow,
      )) {
        _followState.fetchFollowState(n.actorId);
      }
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Toggles follow state for [actorId] with optimistic UI.
  ///
  /// Updates [FollowStateNotifier] immediately so the button flips at once.
  /// Reverts if the API call returns a failure.
  Future<void> toggleFollow(String actorId, bool currentlyFollowing) async {
    _followState.setFollowing(actorId, isFollowing: !currentlyFollowing);
    try {
      final result = currentlyFollowing
          ? await _unfollow(userId: actorId)
          : await _follow(userId: actorId);
      result.fold(
        (_) =>
            _followState.setFollowing(actorId, isFollowing: currentlyFollowing),
        (_) {},
      );
    } catch (_) {
      _followState.setFollowing(actorId, isFollowing: currentlyFollowing);
    }
  }

  /// Toggles like on a comment with optimistic UI.
  ///
  /// Updates [likedCommentIds] immediately and reverts if the API call throws.
  Future<void> toggleCommentLike(String commentId, bool currentIsLiked) async {
    final newSet = Set<String>.from(state.likedCommentIds);
    currentIsLiked ? newSet.remove(commentId) : newSet.add(commentId);
    state = state.copyWith(likedCommentIds: newSet);
    try {
      await _toggleCommentLike(commentId, isCurrentlyLiked: currentIsLiked);
    } catch (_) {
      final revertSet = Set<String>.from(state.likedCommentIds);
      currentIsLiked ? revertSet.add(commentId) : revertSet.remove(commentId);
      state = state.copyWith(likedCommentIds: revertSet);
    }
  }

  /// Called when the socket emits a `notification:created` event.
  /// Bumps [unreadCount] without re-fetching the list.
  void onSocketNotificationCreated() {
    state = state.copyWith(unreadCount: state.unreadCount + 1);
  }

  /// Called when the socket emits a `notification:read` event.
  void onSocketNotificationRead() {
    if (state.unreadCount > 0) {
      state = state.copyWith(unreadCount: state.unreadCount - 1);
    }
  }
}

/// Primary provider for the notifications list and all related actions.
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
        followState: ref.read(followStateProvider.notifier),
      );
    });

/// Derived provider exposing only the unread count.
/// Consumed by the tab bar badge and the app bar.
final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});

/// Wires the WebSocket events to [NotificationsNotifier].
///
/// Only active while the user is authenticated. Listens for
/// `notification:created` and `notification:read` events and delegates
/// to the notifier to update [unreadCount] without a full re-fetch.
final notificationSocketProvider = Provider<void>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is! AuthAuthenticated) return;

  final socket = ref.watch(socketProvider);
  final notifier = ref.read(notificationsProvider.notifier);

  socket.onNotificationCreated((_) => notifier.onSocketNotificationCreated());
  socket.onNotificationRead((_) => notifier.onSocketNotificationRead());
});
