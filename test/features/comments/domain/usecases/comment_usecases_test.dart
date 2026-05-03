import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/comments/domain/entities/comment.dart';
import 'package:rythmify/features/comments/domain/repositories/comment_repository.dart';
import 'package:rythmify/features/comments/domain/usecases/block_user_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/delete_comment_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/get_comment_replies_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/get_floating_comments_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/get_replies_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/get_track_comments_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/post_comment_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/post_reply_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/unblock_user_usecase.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockCommentRepository extends Mock implements CommentRepository {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final tCreatedAt = DateTime(2023, 10, 15);

final tComment = Comment(
  id: 'comment-123',
  trackId: 'track-456',
  userId: 'user-789',
  userDisplayName: 'John Doe',
  content: 'Great track!',
  trackTimestamp: 45000,
  createdAt: tCreatedAt,
  likesCount: 10,
  isLikedByMe: false,
  replyCount: 2,
);

void main() {
  late MockCommentRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(CommentSortType.newest);
  });

  setUp(() {
    mockRepository = MockCommentRepository();
  });

  group('CommentSortTypeExtension', () {
    test('apiValue should return correct string', () {
      expect(CommentSortType.newest.apiValue, 'newest');
      expect(CommentSortType.oldest.apiValue, 'oldest');
      expect(CommentSortType.timestamp.apiValue, 'timestamp');
    });
  });

  // =========================================================================
  // GetTrackCommentsUseCase
  // =========================================================================

  group('GetTrackCommentsUseCase', () {
    late GetTrackCommentsUseCase useCase;

    setUp(() => useCase = GetTrackCommentsUseCase(mockRepository));

    test('should return list of comments from repository', () async {
      when(
        () => mockRepository.getTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => [tComment]);

      final result = await useCase(
        trackId: 'track-456',
        page: 1,
        limit: 20,
        sortType: CommentSortType.newest,
      );

      expect(result, [tComment]);
      verify(
        () => mockRepository.getTrackComments(
          trackId: 'track-456',
          page: 1,
          limit: 20,
          sortType: CommentSortType.newest,
        ),
      ).called(1);
    });
  });

  // =========================================================================
  // GetCommentRepliesUseCase
  // =========================================================================

  group('GetCommentRepliesUseCase', () {
    late GetCommentRepliesUseCase useCase;

    setUp(() => useCase = GetCommentRepliesUseCase(mockRepository));

    test('should return list of replies from repository', () async {
      when(
        () => mockRepository.getCommentReplies(
          commentId: any(named: 'commentId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => [tComment]);

      final result = await useCase(
        commentId: 'comment-123',
        page: 1,
        limit: 20,
        sortType: CommentSortType.newest,
      );

      expect(result, [tComment]);
      verify(
        () => mockRepository.getCommentReplies(
          commentId: 'comment-123',
          page: 1,
          limit: 20,
          sortType: CommentSortType.newest,
        ),
      ).called(1);
    });
  });

  // =========================================================================
  // GetRepliesUseCase
  // =========================================================================

  group('GetRepliesUseCase', () {
    late GetRepliesUseCase useCase;

    setUp(() => useCase = GetRepliesUseCase(mockRepository));

    test('should return offset-based replies from repository', () async {
      when(
        () => mockRepository.getReplies(
          commentId: any(named: 'commentId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [tComment]);

      final result = await useCase(
        commentId: 'comment-123',
        limit: 5,
        offset: 10,
      );

      expect(result, [tComment]);
      verify(
        () => mockRepository.getReplies(
          commentId: 'comment-123',
          limit: 5,
          offset: 10,
        ),
      ).called(1);
    });
  });

  // =========================================================================
  // GetFloatingCommentsUseCase
  // =========================================================================

  group('GetFloatingCommentsUseCase', () {
    late GetFloatingCommentsUseCase useCase;

    setUp(() => useCase = GetFloatingCommentsUseCase(mockRepository));

    test('should return floating comments map from repository', () async {
      final tMap = {45: (pfp: 'https://example.com/pfp.png', text: 'Nice!')};

      when(
        () => mockRepository.getFloatingComments(any()),
      ).thenAnswer((_) async => tMap);

      final result = await useCase('track-456');

      expect(result, tMap);
      verify(() => mockRepository.getFloatingComments('track-456')).called(1);
    });
  });

  // =========================================================================
  // PostCommentUseCase
  // =========================================================================

  group('PostCommentUseCase', () {
    late PostCommentUseCase useCase;

    setUp(() => useCase = PostCommentUseCase(mockRepository));

    test('should post comment and return the created comment', () async {
      when(
        () => mockRepository.postComment(
          trackId: any(named: 'trackId'),
          content: any(named: 'content'),
          trackTimestamp: any(named: 'trackTimestamp'),
          parentId: any(named: 'parentId'),
        ),
      ).thenAnswer((_) async => tComment);

      final result = await useCase(
        trackId: 'track-456',
        content: 'Great track!',
        trackTimestamp: 45000,
        parentId: null,
      );

      expect(result, tComment);
      verify(
        () => mockRepository.postComment(
          trackId: 'track-456',
          content: 'Great track!',
          trackTimestamp: 45000,
          parentId: null,
        ),
      ).called(1);
    });

    test(
      'should throw ArgumentError if content is empty or whitespace',
      () async {
        expect(
          () => useCase(
            trackId: 'track-456',
            content: '   ',
            trackTimestamp: 45000,
          ),
          throwsA(isA<ArgumentError>()),
        );
        verifyNever(
          () => mockRepository.postComment(
            trackId: any(named: 'trackId'),
            content: any(named: 'content'),
            trackTimestamp: any(named: 'trackTimestamp'),
            parentId: any(named: 'parentId'),
          ),
        );
      },
    );
  });

  // =========================================================================
  // PostReplyUseCase
  // =========================================================================

  group('PostReplyUseCase', () {
    late PostReplyUseCase useCase;

    setUp(() => useCase = PostReplyUseCase(mockRepository));

    test('should post a reply and return the created comment', () async {
      when(
        () => mockRepository.postReply(
          commentId: any(named: 'commentId'),
          content: any(named: 'content'),
        ),
      ).thenAnswer((_) async => tComment);

      final result = await useCase(commentId: 'comment-123', content: 'reply');

      expect(result, tComment);
      verify(
        () => mockRepository.postReply(
          commentId: 'comment-123',
          content: 'reply',
        ),
      ).called(1);
    });
  });

  // =========================================================================
  // ToggleCommentLikeUseCase
  // =========================================================================

  group('ToggleCommentLikeUseCase', () {
    late ToggleCommentLikeUseCase useCase;

    setUp(() => useCase = ToggleCommentLikeUseCase(mockRepository));

    test('should return bool indicating like status', () async {
      when(
        () => mockRepository.toggleCommentLike(
          any(),
          isCurrentlyLiked: any(named: 'isCurrentlyLiked'),
        ),
      ).thenAnswer((_) async => true);

      final result = await useCase('comment-123', isCurrentlyLiked: false);

      expect(result, true);
      verify(
        () => mockRepository.toggleCommentLike(
          'comment-123',
          isCurrentlyLiked: false,
        ),
      ).called(1);
    });
  });

  // =========================================================================
  // DeleteCommentUseCase
  // =========================================================================

  group('DeleteCommentUseCase', () {
    late DeleteCommentUseCase useCase;

    setUp(() => useCase = DeleteCommentUseCase(mockRepository));

    test('should call delete on repository', () async {
      when(() => mockRepository.deleteComment(any())).thenAnswer((_) async {});

      await useCase('comment-123');

      verify(() => mockRepository.deleteComment('comment-123')).called(1);
    });
  });

  // =========================================================================
  // BlockUserUseCase
  // =========================================================================

  group('BlockUserUseCase', () {
    late BlockUserUseCase useCase;

    setUp(() => useCase = BlockUserUseCase(mockRepository));

    test('should call blockUser on repository', () async {
      when(() => mockRepository.blockUser(any())).thenAnswer((_) async {});

      await useCase('user-789');

      verify(() => mockRepository.blockUser('user-789')).called(1);
    });
  });

  // =========================================================================
  // UnblockUserUseCase
  // =========================================================================

  group('UnblockUserUseCase', () {
    late UnblockUserUseCase useCase;

    setUp(() => useCase = UnblockUserUseCase(mockRepository));

    test('should call unblockUser on repository', () async {
      when(() => mockRepository.unblockUser(any())).thenAnswer((_) async {});

      await useCase('user-789');

      verify(() => mockRepository.unblockUser('user-789')).called(1);
    });
  });
}
