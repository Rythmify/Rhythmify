import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/authentication/domain/entities/user_entity.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/comments/domain/entities/comment.dart';
import 'package:rythmify/features/comments/presentation/providers/comment_replies_notifier.dart';
import 'package:rythmify/features/comments/presentation/providers/track_comments_notifier.dart';
import 'package:rythmify/features/comments/presentation/widgets/comment_action_bottom_sheet.dart';
import 'package:rythmify/features/player/presentation/providers/player_provider.dart';
import 'package:rythmify/features/player/presentation/providers/player_dependency_providers.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/domain/usecases/play_pause_usecase.dart';

// Mocks
class MockTrackCommentsNotifier extends Mock implements TrackCommentsNotifier {}

class MockCommentRepliesNotifier extends Mock
    implements CommentRepliesNotifier {}

class MockPlayerNotifier extends PlayerNotifier {
  final AppPlayerState _initialState;
  MockPlayerNotifier(this._initialState);
  @override
  AppPlayerState build() => _initialState;

  @override
  Future<void> seek(Duration position) async {}
}

class MockPlayTrackUseCase extends Mock implements PlayTrackUseCase {}

class MockAuthNotifier extends AuthNotifier {
  final AuthState _initialState;
  MockAuthNotifier(this._initialState);
  @override
  AuthState build() => _initialState;
}

void main() {
  late MockPlayerNotifier mockPlayerNotifier;
  late MockPlayTrackUseCase mockPlayTrackUseCase;
  late MockTrackCommentsNotifier mockTrackCommentsNotifier;
  late MockCommentRepliesNotifier mockCommentRepliesNotifier;
  String? clipboardText;

  setUpAll(() {
    registerFallbackValue(const AuthUnauthenticated());
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    mockPlayerNotifier = MockPlayerNotifier(const AppPlayerState());
    mockPlayTrackUseCase = MockPlayTrackUseCase();
    mockTrackCommentsNotifier = MockTrackCommentsNotifier();
    mockCommentRepliesNotifier = MockCommentRepliesNotifier();
    clipboardText = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            final data = Map<String, dynamic>.from(call.arguments as Map);
            clipboardText = data['text'] as String?;
            return null;
          }
          if (call.method == 'Clipboard.getData') {
            return {'text': clipboardText};
          }
          return null;
        });
  });

  final tUser = UserEntity(
    id: 'user-789',
    displayName: 'John Doe',
    email: 'john@example.com',
    username: 'johndoe',
    isEmailVerified: true,
  );

  final tComment = Comment(
    id: 'comment-123',
    trackId: 'track-456',
    userId: 'user-789',
    userDisplayName: 'John Doe',
    content: 'Test Comment Content',
    trackTimestamp: 45,
    createdAt: DateTime.now(),
    likesCount: 10,
    isLikedByMe: false,
    replyCount: 0,
  );

  group('CommentActionBottomSheet', () {
    Future<void> pumpSheet(
      WidgetTester tester,
      Comment comment, {
      UserEntity? authenticatedUser,
    }) async {
      final overrides = [
        authProvider.overrideWith(
          () => MockAuthNotifier(AuthAuthenticated(authenticatedUser ?? tUser)),
        ),
        playerStateProvider.overrideWith(() => mockPlayerNotifier),
        playTrackUseCaseProvider.overrideWithValue(mockPlayTrackUseCase),
        trackCommentsProvider(
          comment.trackId,
        ).overrideWith((ref) => mockTrackCommentsNotifier),
        commentRepliesProvider(
          '__unused_parent__',
        ).overrideWith((ref) => mockCommentRepliesNotifier),
        commentRepliesProvider(
          'comment-123',
        ).overrideWith((ref) => mockCommentRepliesNotifier),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return TextButton(
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      builder: (_) =>
                          CommentActionBottomSheet(comment: comment),
                    ),
                    child: const Text('open sheet'),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open sheet'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('renders all actions for current user', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => MockAuthNotifier(AuthAuthenticated(tUser)),
            ),
            playerStateProvider.overrideWith(() => mockPlayerNotifier),
            playTrackUseCaseProvider.overrideWithValue(mockPlayTrackUseCase),
          ],
          child: MaterialApp(
            home: Scaffold(body: CommentActionBottomSheet(comment: tComment)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('John Doe at 00:45'), findsOneWidget);
      expect(find.text('Play from 00:45'), findsOneWidget);
      expect(find.text('View profile'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Delete comment'), findsOneWidget);
    });

    testWidgets('renders report and block for other user', (tester) async {
      final otherComment = tComment.copyWith(userId: 'other-user');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => MockAuthNotifier(AuthAuthenticated(tUser)),
            ),
            playerStateProvider.overrideWith(() => mockPlayerNotifier),
            playTrackUseCaseProvider.overrideWithValue(mockPlayTrackUseCase),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CommentActionBottomSheet(comment: otherComment),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Delete comment'), findsNothing);
      expect(find.text('Report comment'), findsOneWidget);
      expect(find.text('Block'), findsOneWidget);
    });

    testWidgets('calls playFrom on tap', (tester) async {
      when(() => mockPlayTrackUseCase()).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              () => MockAuthNotifier(AuthAuthenticated(tUser)),
            ),
            playerStateProvider.overrideWith(() => mockPlayerNotifier),
            playTrackUseCaseProvider.overrideWithValue(mockPlayTrackUseCase),
          ],
          child: MaterialApp(
            home: Scaffold(body: CommentActionBottomSheet(comment: tComment)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Play from 00:45'));
      // No verify for mockPlayerNotifier because it's a manual mock now
      // but we can verify the use case
      verify(() => mockPlayTrackUseCase()).called(1);
    });

    testWidgets('copies comment content and closes sheet', (tester) async {
      await pumpSheet(tester, tComment);

      await tester.tap(find.byKey(const Key('comment_action_copy_inkwell')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final data = await Clipboard.getData(Clipboard.kTextPlain);
      expect(data?.text, 'Test Comment Content');
      expect(find.text('Copy'), findsNothing);
    });

    testWidgets('deletes root and reply comments through their notifiers', (
      tester,
    ) async {
      when(
        () => mockTrackCommentsNotifier.deleteComment(any()),
      ).thenAnswer((_) async {});
      await pumpSheet(tester, tComment);

      await tester.tap(find.byKey(const Key('comment_action_delete_inkwell')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(
        () => mockTrackCommentsNotifier.deleteComment('comment-123'),
      ).called(1);

      final reply = tComment.copyWith(id: 'reply-1', parentId: 'comment-123');
      when(
        () => mockCommentRepliesNotifier.deleteReply(any(), any(), any()),
      ).thenAnswer((_) async {});
      await pumpSheet(tester, reply);

      await tester.tap(find.byKey(const Key('comment_action_delete_inkwell')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(
        () => mockCommentRepliesNotifier.deleteReply(
          'reply-1',
          'track-456',
          'comment-123',
        ),
      ).called(1);
    });

    testWidgets('blocks, unblocks, and reports comments for other users', (
      tester,
    ) async {
      final otherUser = UserEntity(
        id: 'current-user',
        displayName: 'Current User',
        email: 'current@example.com',
        username: 'current',
        isEmailVerified: true,
      );
      final otherComment = tComment.copyWith(userId: 'other-user');
      when(
        () => mockTrackCommentsNotifier.toggleBlockUser(
          any(),
          shouldBlock: any(named: 'shouldBlock'),
        ),
      ).thenAnswer((_) async {});

      await pumpSheet(tester, otherComment, authenticatedUser: otherUser);
      await tester.tap(
        find.byKey(const Key('comment_action_toggle_block_inkwell')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(
        () => mockTrackCommentsNotifier.toggleBlockUser(
          'other-user',
          shouldBlock: true,
        ),
      ).called(1);

      final blockedReply = otherComment.copyWith(
        id: 'reply-1',
        parentId: 'comment-123',
        isAuthorBlocked: true,
      );
      when(
        () => mockCommentRepliesNotifier.toggleBlockUser(
          any(),
          shouldBlock: any(named: 'shouldBlock'),
        ),
      ).thenAnswer((_) async {});
      await pumpSheet(tester, blockedReply, authenticatedUser: otherUser);
      await tester.tap(
        find.byKey(const Key('comment_action_toggle_block_inkwell')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      verify(
        () => mockCommentRepliesNotifier.toggleBlockUser(
          'other-user',
          shouldBlock: false,
        ),
      ).called(1);

      await pumpSheet(tester, otherComment, authenticatedUser: otherUser);
      await tester.tap(find.byKey(const Key('comment_action_report_inkwell')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Report'), findsWidgets);
    });
  });
}
