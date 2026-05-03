import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/comments/data/datasources/comment_local_datasource.dart';
import 'package:rythmify/features/comments/data/models/comment_dto.dart';
import 'package:rythmify/features/comments/data/repositories/mock_comment_repository_impl.dart';
import 'package:rythmify/features/comments/domain/repositories/comment_repository.dart';

class MockCommentLocalDataSource extends Mock
    implements CommentLocalDataSource {}

void main() {
  late MockCommentRepositoryImpl repository;
  late MockCommentLocalDataSource localDataSource;

  final dto = CommentDto(
    id: 'comment-1',
    trackId: 'track-1',
    userId: 'user-1',
    userDisplayName: 'User One',
    userPfp: 'pfp.png',
    content: 'hello',
    timestamp: 42,
    createdAt: '2024-01-01T00:00:00.000Z',
    likeCount: 3,
    isLikedByMe: false,
    replyCount: 1,
  );

  setUpAll(() {
    registerFallbackValue(dto);
  });

  setUp(() {
    localDataSource = MockCommentLocalDataSource();
    repository = MockCommentRepositoryImpl(localDataSource);
  });

  group('MockCommentRepositoryImpl', () {
    test('maps track comments, comment replies, and getReplies', () async {
      when(
        () => localDataSource.getTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortValue: any(named: 'sortValue'),
        ),
      ).thenAnswer((_) async => [dto]);
      when(
        () => localDataSource.getCommentReplies(
          commentId: any(named: 'commentId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortValue: any(named: 'sortValue'),
        ),
      ).thenAnswer((_) async => [dto]);
      when(
        () => localDataSource.getReplies(
          commentId: any(named: 'commentId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [dto]);

      final trackComments = await repository.getTrackComments(
        trackId: 'track-1',
        page: 1,
        limit: 20,
        sortType: CommentSortType.oldest,
      );
      final commentReplies = await repository.getCommentReplies(
        commentId: 'comment-1',
        page: 2,
        limit: 10,
        sortType: CommentSortType.timestamp,
      );
      final replies = await repository.getReplies(
        commentId: 'comment-1',
        limit: 5,
        offset: 10,
      );

      expect(trackComments.single.id, dto.id);
      expect(commentReplies.single.id, dto.id);
      expect(replies.single.id, dto.id);
      verify(
        () => localDataSource.getTrackComments(
          trackId: 'track-1',
          page: 1,
          limit: 20,
          sortValue: 'oldest',
        ),
      ).called(1);
      verify(
        () => localDataSource.getCommentReplies(
          commentId: 'comment-1',
          page: 2,
          limit: 10,
          sortValue: 'timestamp',
        ),
      ).called(1);
    });

    test(
      'builds floating comments and keeps the first timestamp entry',
      () async {
        when(
          () => localDataSource.getAllCommentsForTrack(any()),
        ).thenAnswer((_) async => [dto, dto.copyWithForTest(id: 'comment-2')]);

        final result = await repository.getFloatingComments('track-1');

        expect(result, {42: (pfp: 'pfp.png', text: 'hello')});
      },
    );

    test('posts root comments and replies', () async {
      when(
        () => localDataSource.insertComment(any()),
      ).thenAnswer((invocation) async => invocation.positionalArguments.single);
      when(
        () => localDataSource.postReply(
          commentId: any(named: 'commentId'),
          content: any(named: 'content'),
        ),
      ).thenAnswer(
        (_) async => dto.copyWithForTest(parentCommentId: 'comment-1'),
      );

      final comment = await repository.postComment(
        trackId: 'track-1',
        content: 'new',
        trackTimestamp: 12,
        parentId: 'parent-1',
      );
      final reply = await repository.postReply(
        commentId: 'comment-1',
        content: 'reply',
      );

      expect(comment.trackId, 'track-1');
      expect(comment.parentId, 'parent-1');
      expect(reply.parentId, 'comment-1');
      verify(
        () =>
            localDataSource.postReply(commentId: 'comment-1', content: 'reply'),
      ).called(1);
    });

    test('delegates like, delete, block, and unblock', () async {
      when(
        () => localDataSource.toggleLike(any()),
      ).thenAnswer((_) async => true);
      when(() => localDataSource.deleteComment(any())).thenAnswer((_) async {});
      when(() => localDataSource.blockUser(any())).thenAnswer((_) async {});
      when(() => localDataSource.unblockUser(any())).thenAnswer((_) async {});

      expect(
        await repository.toggleCommentLike(
          'comment-1',
          isCurrentlyLiked: false,
        ),
        true,
      );
      await repository.deleteComment('comment-1');
      await repository.blockUser('user-1');
      await repository.unblockUser('user-1');

      verify(() => localDataSource.toggleLike('comment-1')).called(1);
      verify(() => localDataSource.deleteComment('comment-1')).called(1);
      verify(() => localDataSource.blockUser('user-1')).called(1);
      verify(() => localDataSource.unblockUser('user-1')).called(1);
    });

    test('wraps datasource failures with repository context', () async {
      when(
        () => localDataSource.getTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortValue: any(named: 'sortValue'),
        ),
      ).thenThrow(Exception('boom'));
      when(
        () => localDataSource.getCommentReplies(
          commentId: any(named: 'commentId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortValue: any(named: 'sortValue'),
        ),
      ).thenThrow(Exception('boom'));
      when(
        () => localDataSource.getReplies(
          commentId: any(named: 'commentId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenThrow(Exception('boom'));
      when(
        () => localDataSource.getAllCommentsForTrack(any()),
      ).thenThrow(Exception('boom'));
      when(
        () => localDataSource.insertComment(any()),
      ).thenThrow(Exception('boom'));
      when(
        () => localDataSource.postReply(
          commentId: any(named: 'commentId'),
          content: any(named: 'content'),
        ),
      ).thenThrow(Exception('boom'));
      when(
        () => localDataSource.toggleLike(any()),
      ).thenThrow(Exception('boom'));
      when(
        () => localDataSource.deleteComment(any()),
      ).thenThrow(Exception('boom'));
      when(() => localDataSource.blockUser(any())).thenThrow(Exception('boom'));
      when(
        () => localDataSource.unblockUser(any()),
      ).thenThrow(Exception('boom'));

      expect(
        () => repository.getTrackComments(
          trackId: 'track-1',
          page: 1,
          limit: 20,
          sortType: CommentSortType.newest,
        ),
        throwsException,
      );
      expect(
        () => repository.getCommentReplies(
          commentId: 'comment-1',
          page: 1,
          limit: 20,
          sortType: CommentSortType.newest,
        ),
        throwsException,
      );
      expect(
        () =>
            repository.getReplies(commentId: 'comment-1', limit: 5, offset: 0),
        throwsException,
      );
      expect(() => repository.getFloatingComments('track-1'), throwsException);
      expect(
        () => repository.postComment(
          trackId: 'track-1',
          content: 'new',
          trackTimestamp: 1,
        ),
        throwsException,
      );
      expect(
        () => repository.postReply(commentId: 'comment-1', content: 'reply'),
        throwsException,
      );
      expect(
        () =>
            repository.toggleCommentLike('comment-1', isCurrentlyLiked: false),
        throwsException,
      );
      expect(() => repository.deleteComment('comment-1'), throwsException);
      expect(() => repository.blockUser('user-1'), throwsException);
      expect(() => repository.unblockUser('user-1'), throwsException);
    });
  });
}

extension on CommentDto {
  CommentDto copyWithForTest({String? id, String? parentCommentId}) {
    return CommentDto(
      id: id ?? this.id,
      trackId: trackId,
      userId: userId,
      userDisplayName: userDisplayName,
      userPfp: userPfp,
      content: content,
      timestamp: timestamp,
      createdAt: createdAt,
      likeCount: likeCount,
      isLikedByMe: isLikedByMe,
      replyCount: replyCount,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      isAuthorBlocked: isAuthorBlocked,
    );
  }
}
