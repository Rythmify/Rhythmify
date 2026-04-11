import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import 'track_comments_state.dart';
import 'comment_di_providers.dart';
import 'package:flutter_riverpod/legacy.dart';

final trackCommentsProvider =
    StateNotifierProvider.family<
      TrackCommentsNotifier,
      TrackCommentsState,
      String
    >((ref, trackId) {
      return TrackCommentsNotifier(ref, trackId);
    });

class TrackCommentsNotifier extends StateNotifier<TrackCommentsState> {
  final Ref ref;
  final String trackId;

  TrackCommentsNotifier(this.ref, this.trackId)
    : super(TrackCommentsState.initial()) {
    fetchComments();
  }

  void incrementTotalCount() {
    state = state.copyWith(totalCommentCount: state.totalCommentCount + 1);
  }

  void decrementTotalCount() {
    if (state.totalCommentCount > 0) {
      state = state.copyWith(totalCommentCount: state.totalCommentCount - 1);
    }
  }

  Future<void> fetchComments({bool refresh = false}) async {
    if (state.isFetchingNextPage && !refresh) return;

    if (refresh) {
      state = state.copyWith(
        comments: [],
        currentPage: 1,
        hasReachedMax: false,
        isFetchingNextPage: true,
      );
    } else {
      state = state.copyWith(isFetchingNextPage: true);
    }

    try {
      final getTrackComments = ref.read(getTrackCommentsProvider);
      final comments = await getTrackComments(
        trackId: trackId,
        page: state.currentPage,
        sortType: state.sortType,
      );

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
      state = state.copyWith(isFetchingNextPage: false);
    }
  }

  void incrementReplyCount(String commentId) {
    state = state.copyWith(
      comments: state.comments.map((c) {
        if (c.id == commentId) {
          return c.copyWith(replyCount: c.replyCount + 1);
        }
        return c;
      }).toList(),
    );
  }

  void decrementReplyCount(String commentId) {
    state = state.copyWith(
      comments: state.comments.map((c) {
        if (c.id == commentId && c.replyCount > 0) {
          return c.copyWith(replyCount: c.replyCount - 1);
        }
        return c;
      }).toList(),
    );
  }

  void setInitialCount(int initialCount) {
    // Only set it if it's currently 0 (to avoid overwriting live updates)
    if (state.totalCommentCount == 0) {
      state = state.copyWith(totalCommentCount: initialCount);
    }
  }

  Future<void> deleteComment(String commentId) async {
    final originalComments = [...state.comments];
    final originalCount = state.totalCommentCount;

    // Optimistically update list and total count
    state = state.copyWith(
      comments: state.comments.where((c) => c.id != commentId).toList(),
      totalCommentCount: originalCount > 0 ? originalCount - 1 : 0,
    );
    try {
      final deleteCommentUseCase = ref.read(deleteCommentProvider);
      await deleteCommentUseCase(commentId);
    } catch (e) {
      // Revert both on failure
      state = state.copyWith(
        comments: originalComments,
        totalCommentCount: originalCount,
      );
      rethrow;
    }
  }

  Future<void> fetchNextPage() async {
    if (state.hasReachedMax || state.isFetchingNextPage) return;
    await fetchComments();
  }

  void toggleSort(CommentSortType sortType) {
    if (state.sortType == sortType) return;
    state = state.copyWith(sortType: sortType);
    fetchComments(refresh: true);
  }

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

    // Optimistically insert comment and increment total count
    state = state.copyWith(
      comments: [tempComment, ...state.comments],
      totalCommentCount: originalCount + 1,
    );

    try {
      final postComment = ref.read(postCommentProvider);
      final realComment = await postComment(
        trackId: trackId,
        content: content,
        trackTimestamp: trackTimestamp,
      );
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
      // Revert comment list and total count
      state = state.copyWith(
        comments: state.comments.where((c) => c.id != tempComment.id).toList(),
        totalCommentCount: originalCount,
      );
    }
  }

  Future<void> toggleLike(String commentId) async {
    final targetCommentIndex = state.comments.indexWhere(
      (c) => c.id == commentId,
    );
    if (targetCommentIndex == -1) return;

    final currentLikeState = state.comments[targetCommentIndex].isLikedByMe;
    final originalComments = [...state.comments];

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
    try {
      final toggleCommentLike = ref.read(toggleCommentLikeProvider);
      await toggleCommentLike(commentId, isCurrentlyLiked: currentLikeState);
    } catch (e) {
      state = state.copyWith(comments: originalComments);
    }
  }
}
