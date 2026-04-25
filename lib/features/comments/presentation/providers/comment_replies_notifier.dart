import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../domain/entities/comment.dart';
import '../providers/track_comments_notifier.dart';
import 'track_comments_state.dart';
import 'comment_di_providers.dart';
import 'package:flutter_riverpod/legacy.dart';

/// A Riverpod [StateNotifierProvider] that provides a [CommentRepliesNotifier] for a specific parent comment.
///
/// This provider is family-scoped, meaning each parent comment ID gets its own dedicated instance
/// of [CommentRepliesNotifier] and its own isolated [TrackCommentsState].
final commentRepliesProvider =
    StateNotifierProvider.family<
      CommentRepliesNotifier,
      TrackCommentsState,
      String
    >((ref, parentId) {
      return CommentRepliesNotifier(ref, parentId);
    });

/// Manages the state of replies for a specific parent comment.
///
/// This notifier handles fetching, paginating, posting, deleting, and liking replies.
/// It interacts with the Domain use cases and updates its internal [TrackCommentsState].
/// Side effects include cascading reply counts to the parent [TrackCommentsNotifier].
class CommentRepliesNotifier extends StateNotifier<TrackCommentsState> {
  final Ref ref;
  bool _mounted = true;

  @override
  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  /// The unique identifier of the parent comment this notifier is managing replies for.
  final String parentId;

  /// Creates a [CommentRepliesNotifier] and triggers an initial fetch of replies.
  CommentRepliesNotifier(this.ref, this.parentId)
    : super(TrackCommentsState.initial()) {
    fetchReplies();

    // Listen to the global blocked users set to synchronize UI across different notifiers
    ref.listen<Set<String>>(blockedUserIdsProvider, (previous, next) {
      if (mounted) {
        state = state.copyWith(
          comments: state.comments.map((c) {
            return c.copyWith(isAuthorBlocked: next.contains(c.userId));
          }).toList(),
        );
      }
    }, fireImmediately: true);
  }

  /// Fetches a paginated list of replies from the backend.
  ///
  /// If [refresh] is true, it resets the state to page 1 and clears existing comments.
  /// Manages `isFetchingNextPage` and `hasReachedMax` loading states.
  Future<void> fetchReplies({bool refresh = false}) async {
    if (!mounted) return;
    if (state.isFetchingNextPage && !refresh) return;

    if (refresh) {
      if (mounted) {
        state = state.copyWith(
          comments: [],
          currentPage: 1,
          hasReachedMax: false,
          isFetchingNextPage: true,
        );
      }
    } else {
      if (mounted) state = state.copyWith(isFetchingNextPage: true);
    }

    try {
      final getReplies = ref.read(getRepliesProvider);
      final replies = await getReplies(
        commentId: parentId,
        limit: 20,
        offset: (state.currentPage - 1) * 20,
      );

      if (!mounted) return;

      if (replies.isEmpty) {
        state = state.copyWith(hasReachedMax: true, isFetchingNextPage: false);
      } else {
        state = state.copyWith(
          comments: refresh ? replies : [...state.comments, ...replies],
          currentPage: state.currentPage + 1,
          hasReachedMax: replies.length < 20,
          isFetchingNextPage: false,
        );
      }
    } catch (e) {
      if (mounted) state = state.copyWith(isFetchingNextPage: false);
    }
  }

  /// Deletes a specific reply belonging to the current user.
  ///
  /// Optimistically removes the reply from the local state and cascades the deletion
  /// to decrement reply counters in [TrackCommentsNotifier]. Reverts state if backend deletion fails.
  Future<void> deleteReply(
    String commentId,
    String trackId,
    String parentId,
  ) async {
    final originalComments = [...state.comments];
    if (mounted) {
      state = state.copyWith(
        comments: state.comments.where((c) => c.id != commentId).toList(),
      );
    }

    // Decrement parent reply count optimistically
    ref
        .read(trackCommentsProvider(trackId).notifier)
        .decrementReplyCount(parentId);
    // Decrement overall track count optimistically
    ref.read(trackCommentsProvider(trackId).notifier).decrementTotalCount();

    try {
      final deleteCommentUseCase = ref.read(deleteCommentProvider);
      await deleteCommentUseCase(commentId);
    } catch (e) {
      if (mounted) state = state.copyWith(comments: originalComments);
      // Revert decrements
      ref
          .read(trackCommentsProvider(trackId).notifier)
          .incrementReplyCount(parentId);
      ref.read(trackCommentsProvider(trackId).notifier).incrementTotalCount();
      rethrow;
    }
  }

  /// Triggers a fetch for the next page of replies if not currently fetching and not at max.
  Future<void> fetchNextPage() async {
    if (state.hasReachedMax || state.isFetchingNextPage) return;
    await fetchReplies();
  }

  /// Posts a new reply to the parent comment.
  ///
  /// Optimistically inserts a temporary comment into the UI state and increments
  /// corresponding counters. Replaces the temporary comment with the real backend
  /// response upon success. Reverts all optimistic changes on failure.
  Future<void> postReply(
    String trackId,
    String content,
    int trackTimestamp,
  ) async {
    // Get Auth State
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    final user = authState.user;

    final tempReply = Comment(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      userId: user.id,
      userDisplayName: user.displayName,
      userPfp: user.avatarUrl,
      content: content,
      trackTimestamp: trackTimestamp,
      createdAt: DateTime.now(),
      likesCount: 0,
      isLikedByMe: false,
      replyCount: 0,
      parentId: parentId,
    );

    // Instantly show the reply in the UI
    if (mounted) {
      state = state.copyWith(comments: [...state.comments, tempReply]);
    }

    // Instantly increment the parent comment's "Show Replies" counter
    ref
        .read(trackCommentsProvider(trackId).notifier)
        .incrementReplyCount(parentId);
    // Instantly increment overall track count
    ref.read(trackCommentsProvider(trackId).notifier).incrementTotalCount();

    // Send to Server
    try {
      final postReply = ref.read(postReplyProvider);
      final realReply = await postReply(commentId: parentId, content: content);

      if (!mounted) return;

      final populatedRealReply = realReply.copyWith(
        userId: user.id,
        userDisplayName: user.displayName,
        userPfp: user.avatarUrl,
      );

      state = state.copyWith(
        comments: state.comments
            .map((c) => c.id == tempReply.id ? populatedRealReply : c)
            .toList(),
      );
    } catch (e) {
      // Revert UI changes
      if (mounted) {
        state = state.copyWith(
          comments: state.comments.where((c) => c.id != tempReply.id).toList(),
        );
      }
      ref
          .read(trackCommentsProvider(trackId).notifier)
          .decrementReplyCount(parentId);
      ref.read(trackCommentsProvider(trackId).notifier).decrementTotalCount();
    }
  }

  /// Toggles the blocked status for a specific user across all replies in the current state.
  ///
  /// Optimistically updates the `isAuthorBlocked` flag for every reply authored
  /// by the target [userId]. Reverts if the backend request fails.
  Future<void> toggleBlockUser(
    String userId, {
    required bool shouldBlock,
  }) async {
    final originalComments = [...state.comments];
    final originalBlockedUsers = ref.read(blockedUserIdsProvider);

    if (mounted) {
      // 1. Update local state for immediate feedback
      state = state.copyWith(
        comments: state.comments.map((c) {
          if (c.userId == userId) {
            return c.copyWith(isAuthorBlocked: shouldBlock);
          }
          return c;
        }).toList(),
      );

      // 2. Update global provider to sync with other notifiers (top-level or other replies)
      ref.read(blockedUserIdsProvider.notifier).toggle(userId, shouldBlock);
    }

    try {
      if (shouldBlock) {
        final blockUserUseCase = ref.read(blockUserProvider);
        await blockUserUseCase(userId);
      } else {
        final unblockUserUseCase = ref.read(unblockUserProvider);
        await unblockUserUseCase(userId);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(comments: originalComments);
        ref.read(blockedUserIdsProvider.notifier).setAll(originalBlockedUsers);
      }
      rethrow;
    }
  }

  /// Toggles the like status of a specific reply.
  ///
  /// Optimistically updates the like icon and count in the UI before awaiting
  /// the network request. Reverts the state if the backend request fails.
  Future<void> toggleLike(String commentId) async {
    final targetCommentIndex = state.comments.indexWhere(
      (c) => c.id == commentId,
    );
    if (targetCommentIndex == -1) return;

    final currentLikeState = state.comments[targetCommentIndex].isLikedByMe;
    final originalComments = [...state.comments];

    if (mounted) {
      state = state.copyWith(
        comments: state.comments.map((c) {
          if (c.id == commentId) {
            final newIsLiked = !c.isLikedByMe;
            return c.copyWith(
              isLikedByMe: newIsLiked,
              likesCount: newIsLiked ? c.likesCount + 1 : c.likesCount - 1,
            );
          }
          return c;
        }).toList(),
      );
    }
    try {
      final toggleCommentLike = ref.read(toggleCommentLikeProvider);
      final newLikeStatus = await toggleCommentLike(
        commentId,
        isCurrentlyLiked: currentLikeState,
      );

      if (!mounted) return;

      // Synchronize with backend result if it differs from optimistic update
      if (newLikeStatus != !currentLikeState) {
        state = state.copyWith(
          comments: state.comments.map((c) {
            if (c.id == commentId) {
              return c.copyWith(
                isLikedByMe: newLikeStatus,
                likesCount: newLikeStatus ? c.likesCount + 1 : c.likesCount - 1,
              );
            }
            return c;
          }).toList(),
        );
      }
    } catch (e) {
      if (mounted) state = state.copyWith(comments: originalComments);
    }
  }
}
