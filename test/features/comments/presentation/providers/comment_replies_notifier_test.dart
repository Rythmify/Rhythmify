import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/authentication/domain/entities/user_entity.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/comments/domain/entities/comment.dart';
import 'package:rythmify/features/comments/domain/usecases/delete_comment_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/get_comment_replies_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/post_comment_usecase.dart';
import 'package:rythmify/features/comments/domain/usecases/toggle_comment_like_usecase.dart';
import 'package:rythmify/features/comments/presentation/providers/comment_di_providers.dart';
import 'package:rythmify/features/comments/presentation/providers/comment_replies_notifier.dart';
import 'package:rythmify/features/comments/presentation/providers/track_comments_notifier.dart';

// Mocks
class MockGetCommentRepliesUseCase extends Mock implements GetCommentRepliesUseCase {}
class MockDeleteCommentUseCase extends Mock implements DeleteCommentUseCase {}
class MockPostCommentUseCase extends Mock implements PostCommentUseCase {}
class MockToggleCommentLikeUseCase extends Mock implements ToggleCommentLikeUseCase {}

class MockAuthNotifier extends AuthNotifier with Mock {
  final AuthState _initialState;
  MockAuthNotifier(this._initialState);
  @override
  AuthState build() => _initialState;
}

class MockTrackCommentsNotifier extends Mock implements TrackCommentsNotifier {}

void main() {
  late ProviderContainer container;
  late MockGetCommentRepliesUseCase mockGetReplies;
  late MockDeleteCommentUseCase mockDeleteComment;
  late MockPostCommentUseCase mockPostComment;
  late MockToggleCommentLikeUseCase mockToggleCommentLike;
  late MockTrackCommentsNotifier mockTrackCommentsNotifier;

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
    mockGetReplies = MockGetCommentRepliesUseCase();
    mockDeleteComment = MockDeleteCommentUseCase();
    mockPostComment = MockPostCommentUseCase();
    mockToggleCommentLike = MockToggleCommentLikeUseCase();
    mockTrackCommentsNotifier = MockTrackCommentsNotifier();

    container = ProviderContainer(
      overrides: [
        getCommentRepliesProvider.overrideWithValue(mockGetReplies),
        deleteCommentProvider.overrideWithValue(mockDeleteComment),
        postCommentProvider.overrideWithValue(mockPostComment),
        toggleCommentLikeProvider.overrideWithValue(mockToggleCommentLike),
        authProvider.overrideWith(() => MockAuthNotifier(AuthAuthenticated(tUser))),
        trackCommentsProvider('track-456').overrideWith((ref) => mockTrackCommentsNotifier),
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
          page: any(named: 'page'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => [tComment]);

      final sub = container.listen(commentRepliesProvider('comment-123'), (prev, next) {});
      await Future.delayed(Duration.zero);

      final state = container.read(commentRepliesProvider('comment-123'));
      expect(state.comments, [tComment]);
      expect(state.currentPage, 2);
      expect(state.hasReachedMax, true);

      sub.close();
    });

    test('deleteReply optimistically updates and calls tracking methods', () async {
      when(
        () => mockGetReplies(
          commentId: any(named: 'commentId'),
          page: any(named: 'page'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => [tComment]);

      when(() => mockDeleteComment(any())).thenAnswer((_) async {});

      final notifier = container.read(commentRepliesProvider('comment-123').notifier);
      await Future.delayed(Duration.zero);

      await notifier.deleteReply('reply-123', 'track-456', 'comment-123');

      final state = container.read(commentRepliesProvider('comment-123'));
      expect(state.comments, isEmpty);
      verify(() => mockDeleteComment('reply-123')).called(1);
    });

    test('postReply optimistically updates and calls tracking methods', () async {
      when(
        () => mockGetReplies(
          commentId: any(named: 'commentId'),
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
          parentId: any(named: 'parentId'),
        ),
      ).thenAnswer((_) async => returnedComment);

      final notifier = container.read(commentRepliesProvider('comment-123').notifier);
      await Future.delayed(Duration.zero);

      await notifier.postReply('track-456', 'New reply', 1000);

      final state = container.read(commentRepliesProvider('comment-123'));
      expect(state.comments.first.id, 'real-id');
    });

    test('toggleLike optimistically updates', () async {
      when(
        () => mockGetReplies(
          commentId: any(named: 'commentId'),
          page: any(named: 'page'),
          sortType: any(named: 'sortType'),
        ),
      ).thenAnswer((_) async => [tComment]);

      when(() => mockToggleCommentLike(any(), isCurrentlyLiked: any(named: 'isCurrentlyLiked')))
          .thenAnswer((_) async => true);

      final notifier = container.read(commentRepliesProvider('comment-123').notifier);
      await Future.delayed(Duration.zero);

      await notifier.toggleLike('reply-123');

      final state = container.read(commentRepliesProvider('comment-123'));
      expect(state.comments.first.isLikedByMe, true);
      expect(state.comments.first.likesCount, 11);
    });
  });
}
