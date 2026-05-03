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
import 'package:rythmify/features/comments/domain/usecases/get_track_comments_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/post_comment_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/unblock_user_usecase.dart';
import 'package:rythmify/features/comments/presentation/providers/comment_di_providers.dart';
import 'package:rythmify/features/comments/presentation/providers/track_comments_notifier.dart';

class MockGetTrackCommentsUseCase extends Mock
    implements GetTrackCommentsUseCase {}

class MockDeleteCommentUseCase extends Mock implements DeleteCommentUseCase {}

class MockPostCommentUseCase extends Mock implements PostCommentUseCase {}

class MockToggleCommentLikeUseCase extends Mock
    implements ToggleCommentLikeUseCase {}

class MockBlockUserUseCase extends Mock implements BlockUserUseCase {}

class MockUnblockUserUseCase extends Mock implements UnblockUserUseCase {}

class MockAuthNotifier extends AuthNotifier with Mock {
  MockAuthNotifier(this._initialState);

  final AuthState _initialState;

  @override
  AuthState build() => _initialState;
}

void main() {
  late ProviderContainer container;
  late MockGetTrackCommentsUseCase mockGetTrackComments;
  late MockDeleteCommentUseCase mockDeleteComment;
  late MockPostCommentUseCase mockPostComment;
  late MockToggleCommentLikeUseCase mockToggleLike;
  late MockBlockUserUseCase mockBlock;
  late MockUnblockUserUseCase mockUnblock;

  final createdAt = DateTime(2024, 1, 1);
  final tComment = Comment(
    id: 'comment-123',
    trackId: 'track-456',
    userId: 'user-789',
    userDisplayName: 'John Doe',
    content: 'Great track!',
    trackTimestamp: 45,
    createdAt: createdAt,
    likesCount: 10,
    isLikedByMe: false,
    replyCount: 2,
  );

  final tUser = UserEntity(
    id: 'user-789',
    displayName: 'John Doe',
    email: 'john@example.com',
    username: 'johndoe',
    avatarUrl: 'https://example.com/avatar.png',
    isEmailVerified: true,
  );

  Future<void> settle() async {
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  void stubInitialFetch(List<Comment> comments) {
    when(
      () => mockGetTrackComments(
        trackId: any(named: 'trackId'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        sortType: any(named: 'sortType'),
      ),
    ).thenAnswer((_) async => comments);
  }

  ProviderContainer makeContainer({AuthState? authState}) {
    return ProviderContainer(
      overrides: [
        getTrackCommentsProvider.overrideWithValue(mockGetTrackComments),
        deleteCommentProvider.overrideWithValue(mockDeleteComment),
        postCommentProvider.overrideWithValue(mockPostComment),
        toggleCommentLikeProvider.overrideWithValue(mockToggleLike),
        blockUserProvider.overrideWithValue(mockBlock),
        unblockUserProvider.overrideWithValue(mockUnblock),
        authProvider.overrideWith(
          () => MockAuthNotifier(authState ?? AuthAuthenticated(tUser)),
        ),
      ],
    );
  }

  setUpAll(() {
    registerFallbackValue(CommentSortType.newest);
  });

  setUp(() {
    mockGetTrackComments = MockGetTrackCommentsUseCase();
    mockDeleteComment = MockDeleteCommentUseCase();
    mockPostComment = MockPostCommentUseCase();
    mockToggleLike = MockToggleCommentLikeUseCase();
    mockBlock = MockBlockUserUseCase();
    mockUnblock = MockUnblockUserUseCase();
    container = makeContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('TrackCommentsNotifier', () {
    test('initial state fetches comments and advances pagination', () async {
      stubInitialFetch([tComment]);

      final sub = container.listen(
        trackCommentsProvider('track-456'),
        (_, _) {},
      );
      await settle();

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.comments, [tComment]);
      expect(state.currentPage, 2);
      expect(state.hasReachedMax, true);
      expect(state.isFetchingNextPage, false);
      verify(
        () => mockGetTrackComments(
          trackId: 'track-456',
          page: 1,
          sortType: CommentSortType.newest,
        ),
      ).called(1);
      sub.close();
    });

    test('fetchComments marks max when next page is empty', () async {
      stubInitialFetch([]);

      final notifier = container.read(
        trackCommentsProvider('track-456').notifier,
      );
      await settle();

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.comments, isEmpty);
      expect(state.currentPage, 1);
      expect(state.hasReachedMax, true);
      expect(notifier.mounted, true);
    });

    test(
      'fetchComments appends full pages and fetchNextPage stops at max',
      () async {
        final fullPage = List.generate(
          20,
          (index) => tComment.copyWith(id: 'comment-$index'),
        );
        var calls = 0;
        when(
          () => mockGetTrackComments(
            trackId: any(named: 'trackId'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            sortType: any(named: 'sortType'),
          ),
        ).thenAnswer((invocation) async {
          calls++;
          final page = invocation.namedArguments[#page] as int;
          return page == 1 ? fullPage : [tComment.copyWith(id: 'last')];
        });

        final notifier = container.read(
          trackCommentsProvider('track-456').notifier,
        );
        await settle();
        await notifier.fetchNextPage();
        await notifier.fetchNextPage();

        final state = container.read(trackCommentsProvider('track-456'));
        expect(state.comments, hasLength(21));
        expect(state.comments.last.id, 'last');
        expect(state.hasReachedMax, true);
        expect(calls, 2);
      },
    );

    test('toggleSort refreshes only when sort type changes', () async {
      when(
        () => mockGetTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => [tComment]);

      final notifier = container.read(
        trackCommentsProvider('track-456').notifier,
      );
      await settle();

      notifier.toggleSort(CommentSortType.newest);
      await settle();
      notifier.toggleSort(CommentSortType.oldest);
      await settle();

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.sortType, CommentSortType.oldest);
      verify(
        () => mockGetTrackComments(
          trackId: 'track-456',
          page: 1,
          sortType: CommentSortType.oldest,
        ),
      ).called(1);
    });

    test('postNewComment inserts populated real comment on success', () async {
      stubInitialFetch([]);
      when(
        () => mockPostComment(
          trackId: any(named: 'trackId'),
          content: any(named: 'content'),
          trackTimestamp: any(named: 'trackTimestamp'),
        ),
      ).thenAnswer((_) async => tComment.copyWith(userId: 'server-user'));

      final notifier = container.read(
        trackCommentsProvider('track-456').notifier,
      );
      await settle();
      await notifier.postNewComment('Hello', 45);

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.comments.single.id, 'comment-123');
      expect(state.comments.single.userId, tUser.id);
      expect(state.comments.single.userPfp, tUser.avatarUrl);
      expect(state.totalCommentCount, 1);
    });

    test('postNewComment does nothing when unauthenticated', () async {
      container.dispose();
      container = makeContainer(authState: const AuthUnauthenticated());
      stubInitialFetch([]);

      final notifier = container.read(
        trackCommentsProvider('track-456').notifier,
      );
      await settle();
      await notifier.postNewComment('Hello', 45);

      expect(
        container.read(trackCommentsProvider('track-456')).comments,
        isEmpty,
      );
      verifyNever(
        () => mockPostComment(
          trackId: any(named: 'trackId'),
          content: any(named: 'content'),
          trackTimestamp: any(named: 'trackTimestamp'),
        ),
      );
    });

    test('postNewComment rolls back optimistic comment on failure', () async {
      stubInitialFetch([]);
      when(
        () => mockPostComment(
          trackId: any(named: 'trackId'),
          content: any(named: 'content'),
          trackTimestamp: any(named: 'trackTimestamp'),
        ),
      ).thenThrow(Exception('Post failed'));

      final notifier = container.read(
        trackCommentsProvider('track-456').notifier,
      );
      await settle();
      await notifier.postNewComment('Hello', 45);

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.comments, isEmpty);
      expect(state.totalCommentCount, 0);
    });

    test(
      'deleteComment removes comment and reply total, then calls use case',
      () async {
        stubInitialFetch([tComment]);
        when(() => mockDeleteComment(any())).thenAnswer((_) async {});

        final notifier = container.read(
          trackCommentsProvider('track-456').notifier,
        );
        await settle();
        notifier.setInitialCount(5);
        await notifier.deleteComment('comment-123');

        final state = container.read(trackCommentsProvider('track-456'));
        expect(state.comments, isEmpty);
        expect(state.totalCommentCount, 2);
        verify(() => mockDeleteComment('comment-123')).called(1);
      },
    );

    test(
      'deleteComment ignores unknown id and rolls back on failure',
      () async {
        stubInitialFetch([tComment]);
        when(
          () => mockDeleteComment(any()),
        ).thenThrow(Exception('Delete failed'));

        final notifier = container.read(
          trackCommentsProvider('track-456').notifier,
        );
        await settle();
        notifier.setInitialCount(5);

        await notifier.deleteComment('missing');
        expect(container.read(trackCommentsProvider('track-456')).comments, [
          tComment,
        ]);

        await expectLater(
          notifier.deleteComment('comment-123'),
          throwsA(isA<Exception>()),
        );
        final state = container.read(trackCommentsProvider('track-456'));
        expect(state.comments, [tComment]);
        expect(state.totalCommentCount, 5);
      },
    );

    test('reply count and total count helpers clamp where needed', () async {
      stubInitialFetch([tComment.copyWith(replyCount: 0)]);

      final notifier = container.read(
        trackCommentsProvider('track-456').notifier,
      );
      await settle();
      notifier.incrementReplyCount('comment-123');
      notifier.decrementReplyCount('comment-123');
      notifier.decrementReplyCount('comment-123');
      notifier.incrementTotalCount();
      notifier.decrementTotalCount();
      notifier.decrementTotalCount();

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.comments.single.replyCount, 0);
      expect(state.totalCommentCount, 0);
    });

    test(
      'toggleLike syncs differing backend result and rolls back on error',
      () async {
        stubInitialFetch([tComment]);
        var toggleCalls = 0;
        when(
          () => mockToggleLike(
            any(),
            isCurrentlyLiked: any(named: 'isCurrentlyLiked'),
          ),
        ).thenAnswer((_) async {
          toggleCalls++;
          if (toggleCalls == 1) return false;
          throw Exception('Like failed');
        });

        final notifier = container.read(
          trackCommentsProvider('track-456').notifier,
        );
        await settle();

        await notifier.toggleLike('comment-123');
        var state = container.read(trackCommentsProvider('track-456'));
        expect(state.comments.single.isLikedByMe, false);
        expect(state.comments.single.likesCount, 10);

        await notifier.toggleLike('comment-123');
        state = container.read(trackCommentsProvider('track-456'));
        expect(state.comments.single, tComment);

        await notifier.toggleLike('missing');
        verify(
          () => mockToggleLike('comment-123', isCurrentlyLiked: false),
        ).called(2);
      },
    );

    test('toggleBlockUser updates global block set and can unblock', () async {
      stubInitialFetch([tComment]);
      when(() => mockBlock(any())).thenAnswer((_) async {});
      when(() => mockUnblock(any())).thenAnswer((_) async {});

      final notifier = container.read(
        trackCommentsProvider('track-456').notifier,
      );
      await settle();

      await notifier.toggleBlockUser('user-789', shouldBlock: true);
      expect(
        container
            .read(trackCommentsProvider('track-456'))
            .comments
            .single
            .isAuthorBlocked,
        true,
      );
      expect(container.read(blockedUserIdsProvider), contains('user-789'));

      await notifier.toggleBlockUser('user-789', shouldBlock: false);
      expect(
        container
            .read(trackCommentsProvider('track-456'))
            .comments
            .single
            .isAuthorBlocked,
        false,
      );
      expect(
        container.read(blockedUserIdsProvider),
        isNot(contains('user-789')),
      );
      verify(() => mockBlock('user-789')).called(1);
      verify(() => mockUnblock('user-789')).called(1);
    });

    test(
      'toggleBlockUser rolls back local and global state on failure',
      () async {
        stubInitialFetch([tComment]);
        container.read(blockedUserIdsProvider.notifier).add('existing');
        when(() => mockBlock(any())).thenThrow(Exception('Block failed'));

        final notifier = container.read(
          trackCommentsProvider('track-456').notifier,
        );
        await settle();

        await expectLater(
          notifier.toggleBlockUser('user-789', shouldBlock: true),
          throwsA(isA<Exception>()),
        );
        expect(
          container
              .read(trackCommentsProvider('track-456'))
              .comments
              .single
              .isAuthorBlocked,
          false,
        );
        expect(container.read(blockedUserIdsProvider), {'existing'});
      },
    );

    test('blocked users listener updates fetched comments', () async {
      stubInitialFetch([tComment]);

      final sub = container.listen(
        trackCommentsProvider('track-456'),
        (_, _) {},
      );
      await settle();
      container.read(blockedUserIdsProvider.notifier).add('user-789');
      await settle();

      expect(
        container
            .read(trackCommentsProvider('track-456'))
            .comments
            .single
            .isAuthorBlocked,
        true,
      );
      sub.close();
    });
  });
}
