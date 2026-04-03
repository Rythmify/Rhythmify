import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../../profile/presentation/providers/profile_state.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/comment.dart';
import '../providers/track_comments_notifier.dart';
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
    // 1. Get Auth State
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;

    // 2. Grab Profile State (for Avatar and Name)
    final profileState = ref.read(profileProvider);
    String? profilePic;
    String? displayName = user.displayName;

    if (profileState is ProfileLoaded) {
      // NOTE: Make sure '.avatarUrl' and '.displayName' match your Profile model!
      profilePic = profileState.profile.avatarUrl; 
      displayName = profileState.profile.displayName; 
    }

    // 3. Create the Optimistic Temporary Reply
    final tempReply = Comment(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      userId: user.id,
      userDisplayName: displayName,
      userPfp: profilePic,                    
      content: content,
      trackTimestamp: trackTimestamp,
      createdAt: DateTime.now(),
      likesCount: 0,
      isLikedByMe: false,
      replyCount: 0,
      parentId: parentId,
    );

    // 4. Instantly show the reply in the UI
    state = state.copyWith(
      comments: [...state.comments, tempReply],
    );

    // 5. Instantly increment the parent comment's "Show Replies" counter
    ref.read(trackCommentsProvider(trackId).notifier).incrementReplyCount(parentId);

    // 6. Send to Server
    try {
      final postComment = ref.read(postCommentProvider);
      final realReply = await postComment(
        trackId: trackId,
        content: content,
        trackTimestamp: trackTimestamp,
        parentId: parentId,
      );

      // 7. Force the server response to keep your profile data
      final populatedRealReply = realReply.copyWith(
        userDisplayName: displayName,
        userPfp: profilePic,
      );

      // 8. Swap the temporary reply with the final real one
      state = state.copyWith(
        comments: state.comments.map((c) => c.id == tempReply.id ? populatedRealReply : c).toList(),
      );
    } catch (e) {
      // 9. If it fails, remove the temporary reply
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
