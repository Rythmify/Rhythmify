import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/comments/data/datasources/comment_remote_datasource.dart';
import 'package:rythmify/features/comments/data/models/comment_dto.dart';
import 'package:rythmify/features/comments/data/repositories/comment_remote_repository_impl.dart';
import 'package:rythmify/features/comments/domain/entities/comment.dart';
import 'package:rythmify/features/comments/domain/repositories/comment_repository.dart';

class MockCommentRemoteDataSource extends Mock implements CommentRemoteDataSource {}

void main() {
  late CommentRemoteRepositoryImpl repository;
  late MockCommentRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockCommentRemoteDataSource();
    repository = CommentRemoteRepositoryImpl(mockRemoteDataSource);
  });

  final tCommentDto = CommentDto(
    id: 'comment-123',
    trackId: 'track-456',
    userId: 'user-789',
    userDisplayName: 'John Doe',
    userPfp: 'https://example.com/pfp.png',
    content: 'Great track!',
    timestamp: 45000,
    createdAt: '2023-10-15T10:00:00.000Z',
    likeCount: 10,
    isLikedByMe: false,
    replyCount: 2,
    parentCommentId: null,
  );

  group('getTrackComments', () {
    test('should return a list of Comment from DTOs', () async {
      when(
        () => mockRemoteDataSource.getTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortValue: any(named: 'sortValue'),
        ),
      ).thenAnswer((_) async => [tCommentDto]);

      final result = await repository.getTrackComments(
        trackId: 'track-456',
        page: 1,
        limit: 20,
        sortType: CommentSortType.newest,
      );

      expect(result, isA<List<Comment>>());
      expect(result.first.id, tCommentDto.id);
    });

    test('should throw Exception if datasource throws', () async {
      when(
        () => mockRemoteDataSource.getTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortValue: any(named: 'sortValue'),
        ),
      ).thenThrow(Exception('Error'));

      expect(
        () => repository.getTrackComments(
          trackId: 'track-456',
          page: 1,
          limit: 20,
          sortType: CommentSortType.newest,
        ),
        throwsException,
      );
    });
  });

  group('getCommentReplies', () {
    test('should return a list of Comment from DTOs', () async {
      when(
        () => mockRemoteDataSource.getCommentReplies(
          commentId: any(named: 'commentId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortValue: any(named: 'sortValue'),
        ),
      ).thenAnswer((_) async => [tCommentDto]);

      final result = await repository.getCommentReplies(
        commentId: 'comment-123',
        page: 1,
        limit: 20,
        sortType: CommentSortType.newest,
      );

      expect(result, isA<List<Comment>>());
      expect(result.first.id, tCommentDto.id);
    });

    test('should throw Exception if datasource throws', () async {
      when(
        () => mockRemoteDataSource.getCommentReplies(
          commentId: any(named: 'commentId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortValue: any(named: 'sortValue'),
        ),
      ).thenThrow(Exception('Error'));

      expect(
        () => repository.getCommentReplies(
          commentId: 'comment-123',
          page: 1,
          limit: 20,
          sortType: CommentSortType.newest,
        ),
        throwsException,
      );
    });
  });

  group('getFloatingComments', () {
    test('should map all comments to a Map of record', () async {
      when(
        () => mockRemoteDataSource.getAllCommentsForTrack(any()),
      ).thenAnswer((_) async => [tCommentDto]);

      final result = await repository.getFloatingComments('track-456');

      expect(result, isA<Map<int, ({String? pfp, String text})>>());
      expect(result[45000]?.pfp, 'https://example.com/pfp.png');
      expect(result[45000]?.text, 'Great track!');
    });

    test('should throw Exception if datasource throws', () async {
      when(
        () => mockRemoteDataSource.getAllCommentsForTrack(any()),
      ).thenThrow(Exception('Error'));

      expect(
        () => repository.getFloatingComments('track-456'),
        throwsException,
      );
    });
  });

  group('postComment', () {
    test('should post comment and return Domain entity', () async {
      when(
        () => mockRemoteDataSource.postComment(
          trackId: any(named: 'trackId'),
          content: any(named: 'content'),
          trackTimestamp: any(named: 'trackTimestamp'),
          parentId: any(named: 'parentId'),
        ),
      ).thenAnswer((_) async => tCommentDto);

      final result = await repository.postComment(
        trackId: 'track-456',
        content: 'Great track!',
        trackTimestamp: 45000,
      );

      expect(result.id, tCommentDto.id);
    });

    test('should throw Exception if datasource throws', () async {
      when(
        () => mockRemoteDataSource.postComment(
          trackId: any(named: 'trackId'),
          content: any(named: 'content'),
          trackTimestamp: any(named: 'trackTimestamp'),
          parentId: any(named: 'parentId'),
        ),
      ).thenThrow(Exception('Error'));

      expect(
        () => repository.postComment(
          trackId: 'track-456',
          content: 'Great track!',
          trackTimestamp: 45000,
        ),
        throwsException,
      );
    });
  });

  group('toggleCommentLike', () {
    test('should unlike and return false if currently liked', () async {
      when(() => mockRemoteDataSource.unlikeComment(any())).thenAnswer((_) async {});

      final result = await repository.toggleCommentLike('comment-123', isCurrentlyLiked: true);

      expect(result, false);
      verify(() => mockRemoteDataSource.unlikeComment('comment-123')).called(1);
    });

    test('should like and return true if currently not liked', () async {
      when(() => mockRemoteDataSource.likeComment(any())).thenAnswer((_) async {});

      final result = await repository.toggleCommentLike('comment-123', isCurrentlyLiked: false);

      expect(result, true);
      verify(() => mockRemoteDataSource.likeComment('comment-123')).called(1);
    });

    test('should throw Exception if datasource throws', () async {
      when(() => mockRemoteDataSource.likeComment(any())).thenThrow(Exception('Error'));

      expect(
        () => repository.toggleCommentLike('comment-123', isCurrentlyLiked: false),
        throwsException,
      );
    });
  });

  group('deleteComment', () {
    test('should call delete on datasource', () async {
      when(() => mockRemoteDataSource.deleteComment(any())).thenAnswer((_) async {});

      await repository.deleteComment('comment-123');

      verify(() => mockRemoteDataSource.deleteComment('comment-123')).called(1);
    });

    test('should throw Exception if datasource throws', () async {
      when(() => mockRemoteDataSource.deleteComment(any())).thenThrow(Exception('Error'));

      expect(
        () => repository.deleteComment('comment-123'),
        throwsException,
      );
    });
  });

  group('blockUser & unblockUser', () {
    test('should call blockUser on datasource', () async {
      when(() => mockRemoteDataSource.blockUser(any())).thenAnswer((_) async {});
      await repository.blockUser('user-789');
      verify(() => mockRemoteDataSource.blockUser('user-789')).called(1);
    });

    test('should throw Exception if blockUser throws', () async {
      when(() => mockRemoteDataSource.blockUser(any())).thenThrow(Exception('Error'));
      expect(() => repository.blockUser('user-789'), throwsException);
    });

    test('should call unblockUser on datasource', () async {
      when(() => mockRemoteDataSource.unblockUser(any())).thenAnswer((_) async {});
      await repository.unblockUser('user-789');
      verify(() => mockRemoteDataSource.unblockUser('user-789')).called(1);
    });

    test('should throw Exception if unblockUser throws', () async {
      when(() => mockRemoteDataSource.unblockUser(any())).thenThrow(Exception('Error'));
      expect(() => repository.unblockUser('user-789'), throwsException);
    });
  });
}
