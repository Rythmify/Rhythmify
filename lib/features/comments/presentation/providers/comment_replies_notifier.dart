import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../domain/entities/comment.dart';
import 'track_comments_state.dart';
import 'comment_di_providers.dart';
import 'package:flutter_riverpod/legacy.dart';

final commentRepliesProvider = StateNotifierProvider.family<CommentRepliesNotifier, TrackCommentsState, String>((ref, parentId) {
  return CommentRepliesNotifier(ref, parentId);
});

class CommentRepliesNotifier extends StateNotifier<TrackCommentsState> {
  final Ref ref;
  final String parentId;

  CommentRepliesNotifier(this.ref, this.parentId) : super(TrackCommentsState.initial()) {
    fetchReplies();
  }

  Future<void> fetchReplies({bool refresh = false}) async {
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
      final getCommentReplies = ref.read(getCommentRepliesProvider);
      final replies = await getCommentReplies(
        commentId: parentId,
        page: state.currentPage,
        sortType: state.sortType,
      );

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
      state = state.copyWith(isFetchingNextPage: false);
    }
  }

  Future<void> fetchNextPage() async {
    if (state.hasReachedMax || state.isFetchingNextPage) return;
    await fetchReplies();
  }

  Future<void> postReply(String trackId, String content, int trackTimestamp) async {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    final user = authState.user;

    final tempReply = Comment(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      userId: user.id,
      userDisplayName: user.displayName,
      userPfp: null,
      content: content,
      trackTimestamp: trackTimestamp,
      createdAt: DateTime.now(),
      likesCount: 0,
      isLikedByMe: false,
      replyCount: 0,
      parentId: parentId,
    );

    state = state.copyWith(
      comments: [...state.comments, tempReply],
    );

    try {
      final postComment = ref.read(postCommentProvider);
      final realReply = await postComment(
        trackId: trackId,
        content: content,
        trackTimestamp: trackTimestamp,
        parentId: parentId,
      );

      state = state.copyWith(
        comments: state.comments.map((c) => c.id == tempReply.id ? realReply : c).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        comments: state.comments.where((c) => c.id != tempReply.id).toList(),
      );
    }
  }

  Future<void> toggleLike(String commentId) async {
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
      await toggleCommentLike(commentId);
    } catch (e) {
      state = state.copyWith(comments: originalComments);
    }
  }
}
