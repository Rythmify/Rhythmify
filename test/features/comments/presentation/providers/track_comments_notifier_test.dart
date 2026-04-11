import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/authentication/domain/entities/user_entity.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/comments/domain/entities/comment.dart';
import 'package:rythmify/features/comments/domain/repositories/comment_repository.dart';
import 'package:rythmify/features/comments/domain/usecases/delete_comment_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/get_track_comments_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/post_comment_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:rythmify/features/comments/presentation/providers/comment_di_providers.dart';
import 'package:rythmify/features/comments/presentation/providers/track_comments_notifier.dart';

class MockGetTrackCommentsUseCase extends Mock implements GetTrackCommentsUseCase {}
class MockDeleteCommentUseCase extends Mock implements DeleteCommentUseCase {}
class MockPostCommentUseCase extends Mock implements PostCommentUseCase {}
class MockToggleCommentLikeUseCase extends Mock implements ToggleCommentLikeUseCase {}

class MockAuthNotifier extends AuthNotifier with Mock {
  final AuthState _initialState;
  MockAuthNotifier(this._initialState);
  @override
  AuthState build() => _initialState;
}

void main() {
  late ProviderContainer container;
  late MockGetTrackCommentsUseCase mockGetTrackComments;
  late MockDeleteCommentUseCase mockDeleteComment;
  late MockPostCommentUseCase mockPostComment;
  late MockToggleCommentLikeUseCase mockToggleCommentLike;

  final tComment = Comment(
    id: 'comment-123',
    trackId: 'track-456',
    userId: 'user-789',
    userDisplayName: 'John Doe',
    content: 'Great track!',
    trackTimestamp: 45000,
    createdAt: DateTime.now(),
    likesCount: 10,
    isLikedByMe: false,
    replyCount: 2,
  );

  final tUser = UserEntity(
    id: 'user-789',
    displayName: 'John Doe',
    email: 'john@example.com',
    username: 'johndoe',
    isEmailVerified: true,
  );

  setUp(() {
    mockGetTrackComments = MockGetTrackCommentsUseCase();
    mockDeleteComment = MockDeleteCommentUseCase();
    mockPostComment = MockPostCommentUseCase();
    mockToggleCommentLike = MockToggleCommentLikeUseCase();

    container = ProviderContainer(
      overrides: [
        getTrackCommentsProvider.overrideWithValue(mockGetTrackComments),
        deleteCommentProvider.overrideWithValue(mockDeleteComment),
        postCommentProvider.overrideWithValue(mockPostComment),
        toggleCommentLikeProvider.overrideWithValue(mockToggleCommentLike),
        authProvider.overrideWith(() => MockAuthNotifier(AuthAuthenticated(tUser))),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('TrackCommentsNotifier', () {
    test('initial state should fetch comments', () async {
      when(
        () => mockGetTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => [tComment]);

      final sub = container.listen(trackCommentsProvider('track-456'), (prev, next) {});
      
      // Wait for fetch
      await Future.delayed(Duration.zero);

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.comments, [tComment]);
      expect(state.currentPage, 2);
      expect(state.hasReachedMax, true);
      
      sub.close();
    });

    test('incrementTotalCount and decrementTotalCount', () async {
      when(
        () => mockGetTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => []);

      final notifier = container.read(trackCommentsProvider('track-456').notifier);
      await Future.delayed(Duration.zero);

      notifier.setInitialCount(5);
      expect(container.read(trackCommentsProvider('track-456')).totalCommentCount, 5);

      notifier.incrementTotalCount();
      expect(container.read(trackCommentsProvider('track-456')).totalCommentCount, 6);

      notifier.decrementTotalCount();
      expect(container.read(trackCommentsProvider('track-456')).totalCommentCount, 5);
    });

    test('incrementReplyCount and decrementReplyCount', () async {
      when(
        () => mockGetTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => [tComment]);

      final notifier = container.read(trackCommentsProvider('track-456').notifier);
      await Future.delayed(Duration.zero);

      notifier.incrementReplyCount('comment-123');
      expect(
        container.read(trackCommentsProvider('track-456')).comments.first.replyCount,
        3,
      );

      notifier.decrementReplyCount('comment-123');
      expect(
        container.read(trackCommentsProvider('track-456')).comments.first.replyCount,
        2,
      );
    });

    test('deleteComment optimistically updates and reverts on error', () async {
      when(
        () => mockGetTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => [tComment]);

      when(() => mockDeleteComment(any())).thenThrow(Exception('Fail'));

      final notifier = container.read(trackCommentsProvider('track-456').notifier);
      await Future.delayed(Duration.zero);

      notifier.setInitialCount(1);

      expect(
        () => notifier.deleteComment('comment-123'),
        throwsException,
      );
      await Future.delayed(Duration.zero);

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.comments, [tComment]);
      expect(state.totalCommentCount, 1);
    });

    test('postNewComment optimistically updates', () async {
      when(
        () => mockGetTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => []);

      final returnedComment = tComment.copyWith(id: 'real-id');
      when(
        () => mockPostComment(
          trackId: any(named: 'trackId'),
          content: any(named: 'content'),
          trackTimestamp: any(named: 'trackTimestamp'),
        ),
      ).thenAnswer((_) async => returnedComment);

      final notifier = container.read(trackCommentsProvider('track-456').notifier);
      await Future.delayed(Duration.zero);

      await notifier.postNewComment('New comment', 1000);

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.comments.first.id, 'real-id');
      expect(state.totalCommentCount, 1);
    });

    test('toggleLike optimistically updates', () async {
      when(
        () => mockGetTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => [tComment]);

      when(() => mockToggleCommentLike(any(), isCurrentlyLiked: any(named: 'isCurrentlyLiked')))
          .thenAnswer((_) async => true);

      final notifier = container.read(trackCommentsProvider('track-456').notifier);
      await Future.delayed(Duration.zero);

      await notifier.toggleLike('comment-123');

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.comments.first.isLikedByMe, true);
      expect(state.comments.first.likesCount, 11);
    });

    test('toggleSort fetches new data', () async {
      when(
        () => mockGetTrackComments(
          trackId: any(named: 'trackId'),
          page: any(named: 'page'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => []);

      final notifier = container.read(trackCommentsProvider('track-456').notifier);
      await Future.delayed(Duration.zero);

      notifier.toggleSort(CommentSortType.oldest);
      await Future.delayed(Duration.zero);

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.sortType, CommentSortType.oldest);
    });

    test('fetchNextPage triggers pagination', () async {
      when(
        () => mockGetTrackComments(
          trackId: any(named: 'trackId'),
          page: 1,
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => List.generate(20, (i) => tComment.copyWith(id: 'c$i')));
      
      when(
        () => mockGetTrackComments(
          trackId: any(named: 'trackId'),
          page: 2,
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => [tComment.copyWith(id: 'c20')]);

      final notifier = container.read(trackCommentsProvider('track-456').notifier);
      await Future.delayed(Duration.zero);

      expect(container.read(trackCommentsProvider('track-456')).comments.length, 20);

      await notifier.fetchNextPage();

      final state = container.read(trackCommentsProvider('track-456'));
      expect(state.comments.length, 21);
      expect(state.hasReachedMax, true);
    });
  });
}
