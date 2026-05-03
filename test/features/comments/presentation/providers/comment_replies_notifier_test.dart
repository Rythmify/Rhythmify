import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/authentication/domain/entities/user_entity.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/comments/domain/entities/comment.dart';
import 'package:rythmify/features/comments/domain/repositories/comment_repository.dart';
import 'package:rythmify/features/comments/domain/usecases/block_user_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/delete_comment_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/get_replies_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/post_reply_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/unblock_user_usecase.dart';
import 'package:rythmify/features/comments/presentation/providers/comment_di_providers.dart';
import 'package:rythmify/features/comments/presentation/providers/comment_replies_notifier.dart';
import 'package:rythmify/features/comments/presentation/providers/track_comments_notifier.dart';

// Mocks
class MockGetRepliesUseCase extends Mock implements GetRepliesUseCase {}

class MockDeleteCommentUseCase extends Mock implements DeleteCommentUseCase {}

class MockPostReplyUseCase extends Mock implements PostReplyUseCase {}

class MockToggleCommentLikeUseCase extends Mock
    implements ToggleCommentLikeUseCase {}

class MockBlockUserUseCase extends Mock implements BlockUserUseCase {}

class MockUnblockUserUseCase extends Mock implements UnblockUserUseCase {}

class MockAuthNotifier extends AuthNotifier with Mock {
  final AuthState _initialState;
  MockAuthNotifier(this._initialState);
  @override
  AuthState build() => _initialState;
}

class MockTrackCommentsNotifier extends Mock implements TrackCommentsNotifier {}

void main() {
  late ProviderContainer container;
  late MockGetRepliesUseCase mockGetReplies;
  late MockDeleteCommentUseCase mockDeleteComment;
  late MockPostReplyUseCase mockPostReply;
  late MockToggleCommentLikeUseCase mockToggleCommentLike;
  late MockBlockUserUseCase mockBlock;
  late MockUnblockUserUseCase mockUnblock;
  late MockTrackCommentsNotifier mockTrackCommentsNotifier;

  setUpAll(() {
    registerFallbackValue(CommentSortType.newest);
    registerFallbackValue(const AuthUnauthenticated());
  });

  final tComment = Comment(
    id: 'reply-123',
    trackId: 'track-456',
    userId: 'user-789',
    userDisplayName: 'John Doe',
    content: 'Great reply!',
    trackTimestamp: 45000,
    createdAt: DateTime.now(),
    likesCount: 10,
    isLikedByMe: false,
    replyCount: 0,
    parentId: 'comment-123',
  );

  final tUser = UserEntity(
    id: 'user-789',
    displayName: 'John Doe',
    email: 'john@example.com',
    username: 'johndoe',
    isEmailVerified: true,
  );

  setUp(() {
    mockGetReplies = MockGetRepliesUseCase();
    mockDeleteComment = MockDeleteCommentUseCase();
    mockPostReply = MockPostReplyUseCase();
    mockToggleCommentLike = MockToggleCommentLikeUseCase();
    mockBlock = MockBlockUserUseCase();
    mockUnblock = MockUnblockUserUseCase();
    mockTrackCommentsNotifier = MockTrackCommentsNotifier();

    container = ProviderContainer(
      overrides: [
        getRepliesProvider.overrideWithValue(mockGetReplies),
        deleteCommentProvider.overrideWithValue(mockDeleteComment),
        postReplyProvider.overrideWithValue(mockPostReply),
        toggleCommentLikeProvider.overrideWithValue(mockToggleCommentLike),
        blockUserProvider.overrideWithValue(mockBlock),
        unblockUserProvider.overrideWithValue(mockUnblock),
        authProvider.overrideWith(
          () => MockAuthNotifier(AuthAuthenticated(tUser)),
        ),
        trackCommentsProvider(
          'track-456',
        ).overrideWith((ref) => mockTrackCommentsNotifier),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CommentRepliesNotifier', () {
    test('initial state should fetch replies', () async {
      when(
        () => mockGetReplies(
          commentId: any(named: 'commentId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [tComment]);

      final sub = container.listen(
        commentRepliesProvider('comment-123'),
        (prev, next) {},
      );
      await Future.delayed(Duration.zero);

      final state = container.read(commentRepliesProvider('comment-123'));
      expect(state.comments, [tComment]);
      expect(state.currentPage, 2);
      expect(state.hasReachedMax, true);

      sub.close();
    });

    test(
      'deleteReply optimistically updates and calls tracking methods',
      () async {
        when(
          () => mockGetReplies(
            commentId: any(named: 'commentId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [tComment]);

        when(() => mockDeleteComment(any())).thenAnswer((_) async {});

        final notifier = container.read(
          commentRepliesProvider('comment-123').notifier,
        );
        await Future.delayed(Duration.zero);

        await notifier.deleteReply('reply-123', 'track-456', 'comment-123');

        final state = container.read(commentRepliesProvider('comment-123'));
        expect(state.comments, isEmpty);
        verify(() => mockDeleteComment('reply-123')).called(1);
      },
    );

    test(
      'postReply optimistically updates and calls tracking methods',
      () async {
        when(
          () => mockGetReplies(
            commentId: any(named: 'commentId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => []);

        final returnedComment = tComment.copyWith(id: 'real-id');
        when(
          () => mockPostReply(
            commentId: any(named: 'commentId'),
            content: any(named: 'content'),
          ),
        ).thenAnswer((_) async => returnedComment);

        final notifier = container.read(
          commentRepliesProvider('comment-123').notifier,
        );
        await Future.delayed(Duration.zero);

        await notifier.postReply('track-456', 'New reply', 1000);

        final state = container.read(commentRepliesProvider('comment-123'));
        expect(state.comments.first.id, 'real-id');
      },
    );

    test('toggleLike optimistically updates', () async {
      when(
        () => mockGetReplies(
          commentId: any(named: 'commentId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [tComment]);

      when(
        () => mockToggleCommentLike(
          any(),
          isCurrentlyLiked: any(named: 'isCurrentlyLiked'),
        ),
      ).thenAnswer((_) async => true);

      final notifier = container.read(
        commentRepliesProvider('comment-123').notifier,
      );
      await Future.delayed(Duration.zero);

      await notifier.toggleLike('reply-123');

      final state = container.read(commentRepliesProvider('comment-123'));
      expect(state.comments.first.isLikedByMe, true);
      expect(state.comments.first.likesCount, 11);
    });

    test(
      'fetchReplies refreshes, appends, handles failures, and stops at max',
      () async {
        final firstPage = List.generate(
          20,
          (index) => tComment.copyWith(id: 'reply-$index'),
        );
        var calls = 0;
        when(
          () => mockGetReplies(
            commentId: any(named: 'commentId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((invocation) async {
          calls++;
          final offset = invocation.namedArguments[#offset] as int;
          if (calls == 1) return firstPage;
          if (calls == 2) return [tComment.copyWith(id: 'reply-last')];
          if (offset == 0) return [tComment.copyWith(id: 'reply-refresh')];
          throw Exception('fetch failed');
        });

        final notifier = container.read(
          commentRepliesProvider('comment-123').notifier,
        );
        await Future.delayed(Duration.zero);
        await notifier.fetchNextPage();
        await notifier.fetchNextPage();

        var state = container.read(commentRepliesProvider('comment-123'));
        expect(state.comments, hasLength(21));
        expect(state.hasReachedMax, true);

        await notifier.fetchReplies(refresh: true);
        state = container.read(commentRepliesProvider('comment-123'));
        expect(state.comments.single.id, 'reply-refresh');
        expect(state.currentPage, 2);
        expect(state.isFetchingNextPage, false);
      },
    );

    test('initial fetch failure clears loading state', () async {
      when(
        () => mockGetReplies(
          commentId: any(named: 'commentId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenThrow(Exception('fetch failed'));

      container.read(commentRepliesProvider('comment-123').notifier);
      await Future.delayed(Duration.zero);

      final state = container.read(commentRepliesProvider('comment-123'));
      expect(state.comments, isEmpty);
      expect(state.isFetchingNextPage, false);
    });

    test(
      'deleteReply rolls back and restores parent counts on failure',
      () async {
        when(
          () => mockGetReplies(
            commentId: any(named: 'commentId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [tComment]);
        when(
          () => mockDeleteComment(any()),
        ).thenThrow(Exception('delete failed'));

        final notifier = container.read(
          commentRepliesProvider('comment-123').notifier,
        );
        await Future.delayed(Duration.zero);

        await expectLater(
          notifier.deleteReply('reply-123', 'track-456', 'comment-123'),
          throwsA(isA<Exception>()),
        );

        final state = container.read(commentRepliesProvider('comment-123'));
        expect(state.comments, [tComment]);
        verify(
          () => mockTrackCommentsNotifier.incrementReplyCount('comment-123'),
        ).called(1);
        verify(() => mockTrackCommentsNotifier.incrementTotalCount()).called(1);
      },
    );

    test(
      'postReply does nothing when unauthenticated and rolls back on failure',
      () async {
        container.dispose();
        mockTrackCommentsNotifier = MockTrackCommentsNotifier();
        container = ProviderContainer(
          overrides: [
            getRepliesProvider.overrideWithValue(mockGetReplies),
            deleteCommentProvider.overrideWithValue(mockDeleteComment),
            postReplyProvider.overrideWithValue(mockPostReply),
            toggleCommentLikeProvider.overrideWithValue(mockToggleCommentLike),
            blockUserProvider.overrideWithValue(mockBlock),
            unblockUserProvider.overrideWithValue(mockUnblock),
            authProvider.overrideWith(
              () => MockAuthNotifier(const AuthUnauthenticated()),
            ),
            trackCommentsProvider(
              'track-456',
            ).overrideWith((ref) => mockTrackCommentsNotifier),
          ],
        );
        when(
          () => mockGetReplies(
            commentId: any(named: 'commentId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => []);

        var notifier = container.read(
          commentRepliesProvider('comment-123').notifier,
        );
        await Future.delayed(Duration.zero);
        await notifier.postReply('track-456', 'ignored', 1);

        verifyNever(
          () => mockPostReply(
            commentId: any(named: 'commentId'),
            content: any(named: 'content'),
          ),
        );

        container.dispose();
        mockTrackCommentsNotifier = MockTrackCommentsNotifier();
        container = ProviderContainer(
          overrides: [
            getRepliesProvider.overrideWithValue(mockGetReplies),
            deleteCommentProvider.overrideWithValue(mockDeleteComment),
            postReplyProvider.overrideWithValue(mockPostReply),
            toggleCommentLikeProvider.overrideWithValue(mockToggleCommentLike),
            blockUserProvider.overrideWithValue(mockBlock),
            unblockUserProvider.overrideWithValue(mockUnblock),
            authProvider.overrideWith(
              () => MockAuthNotifier(AuthAuthenticated(tUser)),
            ),
            trackCommentsProvider(
              'track-456',
            ).overrideWith((ref) => mockTrackCommentsNotifier),
          ],
        );
        when(
          () => mockPostReply(
            commentId: any(named: 'commentId'),
            content: any(named: 'content'),
          ),
        ).thenThrow(Exception('post failed'));

        notifier = container.read(
          commentRepliesProvider('comment-123').notifier,
        );
        await Future.delayed(Duration.zero);
        await notifier.postReply('track-456', 'will rollback', 1);

        final state = container.read(commentRepliesProvider('comment-123'));
        expect(state.comments, isEmpty);
        verify(
          () => mockTrackCommentsNotifier.decrementReplyCount('comment-123'),
        ).called(1);
        verify(() => mockTrackCommentsNotifier.decrementTotalCount()).called(1);
      },
    );

    test('toggleBlockUser handles block, unblock, and rollback', () async {
      when(
        () => mockGetReplies(
          commentId: any(named: 'commentId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [tComment]);
      when(() => mockBlock(any())).thenAnswer((_) async {});
      when(() => mockUnblock(any())).thenAnswer((_) async {});

      final notifier = container.read(
        commentRepliesProvider('comment-123').notifier,
      );
      await Future.delayed(Duration.zero);

      await notifier.toggleBlockUser('user-789', shouldBlock: true);
      expect(
        container
            .read(commentRepliesProvider('comment-123'))
            .comments
            .single
            .isAuthorBlocked,
        true,
      );

      await notifier.toggleBlockUser('user-789', shouldBlock: false);
      expect(
        container
            .read(commentRepliesProvider('comment-123'))
            .comments
            .single
            .isAuthorBlocked,
        false,
      );

      when(() => mockBlock(any())).thenThrow(Exception('block failed'));
      await expectLater(
        notifier.toggleBlockUser('user-789', shouldBlock: true),
        throwsA(isA<Exception>()),
      );
      expect(
        container
            .read(commentRepliesProvider('comment-123'))
            .comments
            .single
            .isAuthorBlocked,
        false,
      );
    });

    test(
      'toggleLike syncs backend mismatch, rolls back, and ignores unknown ids',
      () async {
        when(
          () => mockGetReplies(
            commentId: any(named: 'commentId'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [tComment]);
        var calls = 0;
        when(
          () => mockToggleCommentLike(
            any(),
            isCurrentlyLiked: any(named: 'isCurrentlyLiked'),
          ),
        ).thenAnswer((_) async {
          calls++;
          if (calls == 1) return false;
          throw Exception('like failed');
        });

        final notifier = container.read(
          commentRepliesProvider('comment-123').notifier,
        );
        await Future.delayed(Duration.zero);

        await notifier.toggleLike('reply-123');
        var state = container.read(commentRepliesProvider('comment-123'));
        expect(state.comments.single.isLikedByMe, false);
        expect(state.comments.single.likesCount, 10);

        await notifier.toggleLike('reply-123');
        state = container.read(commentRepliesProvider('comment-123'));
        expect(state.comments.single, tComment);

        await notifier.toggleLike('missing');
        verify(
          () => mockToggleCommentLike('reply-123', isCurrentlyLiked: false),
        ).called(2);
      },
    );
  });
}
