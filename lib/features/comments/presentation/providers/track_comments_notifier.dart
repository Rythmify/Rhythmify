import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import 'track_comments_state.dart';
import 'comment_di_providers.dart';
import 'package:flutter_riverpod/legacy.dart';

/// A Riverpod [StateNotifierProvider] that provides a [TrackCommentsNotifier] for a specific track.
///
/// This provider is family-scoped, meaning each track ID gets its own dedicated
/// [TrackCommentsNotifier] instance managing an isolated [TrackCommentsState].
final trackCommentsProvider =
    StateNotifierProvider.family<
      TrackCommentsNotifier,
      TrackCommentsState,
      String
    >((ref, trackId) {
      return TrackCommentsNotifier(ref, trackId);
    });

/// Manages the root comments state for a specific track.
///
/// Handles fetching paginated comments, sorting, posting new root comments,
/// deleting comments, and toggling likes. Optimistically updates its internal
/// [TrackCommentsState] for immediate UI feedback.
class TrackCommentsNotifier extends StateNotifier<TrackCommentsState> {
  final Ref ref;
  bool _mounted = true;

  @override
  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  /// The unique identifier of the track this notifier manages comments for.
  final String trackId;

  /// Creates a [TrackCommentsNotifier] and triggers an initial fetch of root comments.
  TrackCommentsNotifier(this.ref, this.trackId)
    : super(TrackCommentsState.initial()) {
    fetchComments();
  }

  /// Increments the total comment count displayed on the track UI.
  void incrementTotalCount() {
    if (mounted)
      state = state.copyWith(totalCommentCount: state.totalCommentCount + 1);
  }

  /// Decrements the total comment count displayed on the track UI safely above 0.
  void decrementTotalCount() {
    if (mounted && state.totalCommentCount > 0) {
      state = state.copyWith(totalCommentCount: state.totalCommentCount - 1);
    }
  }

  /// Fetches a paginated list of root comments from the backend.
  ///
  /// If [refresh] is true, resets pagination to page 1 and clears existing comments.
  /// Updates `isFetchingNextPage` and `hasReachedMax` loading states accordingly.
  Future<void> fetchComments({bool refresh = false}) async {
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
      final getTrackComments = ref.read(getTrackCommentsProvider);
      final comments = await getTrackComments(
        trackId: trackId,
        page: state.currentPage,
        sortType: state.sortType,
      );

      if (!mounted) return;

      if (comments.isEmpty) {
        state = state.copyWith(hasReachedMax: true, isFetchingNextPage: false);
      } else {
        state = state.copyWith(
          comments: refresh ? comments : [...state.comments, ...comments],
          currentPage: state.currentPage + 1,
          hasReachedMax: comments.length < 20,
          isFetchingNextPage: false,
        );
      }
    } catch (e) {
      if (mounted) state = state.copyWith(isFetchingNextPage: false);
    }
  }

  /// Increments the reply count of a specific root comment in the local state.
  void incrementReplyCount(String commentId) {
    if (mounted) {
      state = state.copyWith(
        comments: state.comments.map((c) {
          if (c.id == commentId) {
            return c.copyWith(replyCount: c.replyCount + 1);
          }
          return c;
        }).toList(),
      );
    }
  }

  /// Decrements the reply count of a specific root comment in the local state.
  void decrementReplyCount(String commentId) {
    if (mounted) {
      state = state.copyWith(
        comments: state.comments.map((c) {
          if (c.id == commentId && c.replyCount > 0) {
            return c.copyWith(replyCount: c.replyCount - 1);
          }
          return c;
        }).toList(),
      );
    }
  }

  /// Sets the initial total comment count from external track metadata.
  void setInitialCount(int initialCount) {
    if (mounted && state.totalCommentCount == 0) {
      state = state.copyWith(totalCommentCount: initialCount);
    }
  }

  /// Deletes a specific root comment belonging to the current user.
  ///
  /// Optimistically removes the comment from the local state. Reverts the state
  /// if the backend deletion fails.
  Future<void> deleteComment(String commentId) async {
    final originalComments = [...state.comments];
    final originalCount = state.totalCommentCount;

    if (mounted) {
      state = state.copyWith(
        comments: state.comments.where((c) => c.id != commentId).toList(),
        totalCommentCount: originalCount > 0 ? originalCount - 1 : 0,
      );
    }
    try {
      final deleteCommentUseCase = ref.read(deleteCommentProvider);
      await deleteCommentUseCase(commentId);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          comments: originalComments,
          totalCommentCount: originalCount,
        );
      }
      rethrow;
    }
  }

  /// Triggers a fetch for the next page of comments.
  Future<void> fetchNextPage() async {
    if (state.hasReachedMax || state.isFetchingNextPage) return;
    await fetchComments();
  }

  /// Toggles the comment sorting strategy and refreshes the list from page 1.
  void toggleSort(CommentSortType sortType) {
    if (state.sortType == sortType) return;
    if (mounted) state = state.copyWith(sortType: sortType);
    fetchComments(refresh: true);
  }

  /// Posts a new root comment to the track.
  ///
  /// Optimistically inserts a temporary comment into the UI state and replaces
  /// it with the actual backend response upon success. Reverts on failure.
  Future<void> postNewComment(String content, int trackTimestamp) async {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    final user = authState.user;

    final tempComment = Comment(
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
    );

    final originalCount = state.totalCommentCount;

    if (mounted) {
      state = state.copyWith(
        comments: [tempComment, ...state.comments],
        totalCommentCount: originalCount + 1,
      );
    }

    try {
      final postComment = ref.read(postCommentProvider);
      final realComment = await postComment(
        trackId: trackId,
        content: content,
        trackTimestamp: trackTimestamp,
      );

      if (!mounted) return;

      final populatedRealComment = realComment.copyWith(
        userId: user.id,
        userDisplayName: user.displayName,
        userPfp: user.avatarUrl,
      );
      state = state.copyWith(
        comments: state.comments
            .map((c) => c.id == tempComment.id ? populatedRealComment : c)
            .toList(),
      );
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          comments: state.comments
              .where((c) => c.id != tempComment.id)
              .toList(),
          totalCommentCount: originalCount,
        );
      }
    }
  }

  /// Toggles the like status of a specific root comment.
  ///
  /// Optimistically updates the like icon and count in the UI before awaiting
  /// the network request. Reverts the state if the request fails.
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

      // If the backend returned a different status than our optimistic update, sync it.
      // This is especially important if the user said "make the state to be known".
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
