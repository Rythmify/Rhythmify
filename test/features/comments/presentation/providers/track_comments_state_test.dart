import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/comments/domain/entities/comment.dart';
import 'package:rythmify/features/comments/domain/repositories/comment_repository.dart';
import 'package:rythmify/features/comments/presentation/providers/track_comments_state.dart';

void main() {
  final tComment = Comment(
    id: 'comment-123',
    trackId: 'track-456',
    userId: 'user-789',
    userDisplayName: 'John Doe',
    content: 'Great track!',
    trackTimestamp: 45000,
    createdAt: DateTime(2023, 10, 15),
    likesCount: 10,
    isLikedByMe: false,
    replyCount: 2,
  );

  group('TrackCommentsState', () {
    test('initial should return expected default state', () {
      final state = TrackCommentsState.initial();

      expect(state.comments, isEmpty);
      expect(state.currentPage, 1);
      expect(state.hasReachedMax, false);
      expect(state.isFetchingNextPage, false);
      expect(state.sortType, CommentSortType.newest);
      expect(state.totalCommentCount, 0);
    });

    test('copyWith should replace fields properly', () {
      final state = TrackCommentsState.initial();

      final updatedState = state.copyWith(
        comments: [tComment],
        currentPage: 2,
        hasReachedMax: true,
        isFetchingNextPage: true,
        sortType: CommentSortType.oldest,
        totalCommentCount: 5,
      );

      expect(updatedState.comments, [tComment]);
      expect(updatedState.currentPage, 2);
      expect(updatedState.hasReachedMax, true);
      expect(updatedState.isFetchingNextPage, true);
      expect(updatedState.sortType, CommentSortType.oldest);
      expect(updatedState.totalCommentCount, 5);
    });

    test('copyWith should retain old values if not provided', () {
      final state = TrackCommentsState.initial().copyWith(
        comments: [tComment],
        totalCommentCount: 10,
      );

      final updatedState = state.copyWith(currentPage: 5);

      expect(updatedState.comments, [tComment]);
      expect(updatedState.currentPage, 5);
      expect(updatedState.hasReachedMax, state.hasReachedMax);
      expect(updatedState.isFetchingNextPage, state.isFetchingNextPage);
      expect(updatedState.sortType, state.sortType);
      expect(updatedState.totalCommentCount, 10);
    });

    test('props should contain all fields', () {
      final state = TrackCommentsState.initial();
      expect(state.props.length, 6);
      expect(
        state.props,
        containsAll([
          state.comments,
          state.currentPage,
          state.hasReachedMax,
          state.isFetchingNextPage,
          state.sortType,
          state.totalCommentCount,
        ]),
      );
    });
  });
}
