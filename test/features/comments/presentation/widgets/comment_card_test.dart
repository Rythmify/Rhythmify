import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/comments/domain/entities/comment.dart';
import 'package:rythmify/features/comments/presentation/widgets/comment_card.dart';
import 'package:go_router/go_router.dart';

class MockGoRouter extends Mock implements GoRouter {}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return createMockHttpClient(context);
  }
}

class MockHttpClient extends Mock implements HttpClient {}
class MockHttpClientRequest extends Mock implements HttpClientRequest {}
class MockHttpClientResponse extends Mock implements HttpClientResponse {}
class MockHttpHeaders extends Mock implements HttpHeaders {}

MockHttpClient createMockHttpClient(SecurityContext? context) {
  final client = MockHttpClient();
  final request = MockHttpClientRequest();
  final response = MockHttpClientResponse();
  final headers = MockHttpHeaders();

  final bytes = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82];

  when(() => client.getUrl(any())).thenAnswer((_) async => request);
  when(() => request.headers).thenReturn(headers);
  when(() => request.close()).thenAnswer((_) async => response);
  when(() => response.statusCode).thenReturn(200);
  when(() => response.contentLength).thenReturn(bytes.length);
  when(() => response.compressionState).thenReturn(HttpClientResponseCompressionState.notCompressed);
  when(() => response.listen(any(), onDone: any(named: 'onDone'), onError: any(named: 'onError'), cancelOnError: any(named: 'cancelOnError'))).thenAnswer((invocation) {
    final onData = invocation.positionalArguments[0] as void Function(List<int>);
    final onDone = invocation.namedArguments[#onDone] as void Function()?;
    onData(bytes);
    onDone?.call();
    return MockStreamSubscription<List<int>>();
  });

  return client;
}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {
  @override
  Future<void> cancel() async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    HttpOverrides.global = TestHttpOverrides();
  });

  final tComment = Comment(
    id: 'comment-123',
    trackId: 'track-456',
    userId: 'user-789',
    userDisplayName: 'John Doe',
    content: 'Test Comment Content',
    trackTimestamp: 45, // 45 seconds -> 00:45
    createdAt: DateTime.now(),
    likesCount: 10,
    isLikedByMe: false,
    replyCount: 2,
  );

  group('CommentCard', () {
    testWidgets('renders correct information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentCard(comment: tComment),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Test Comment Content'), findsOneWidget);
      expect(find.text('00:45'), findsOneWidget); // formatted timestamp
      expect(find.text('10'), findsOneWidget); // likes count
    });

    testWidgets('calls onLike when like button is pressed', (tester) async {
      bool likePressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentCard(
              comment: tComment,
              onLike: () => likePressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(likePressed, isTrue);
    });

    testWidgets('calls onReply when reply button is pressed', (tester) async {
      bool replyPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentCard(
              comment: tComment,
              onReply: () => replyPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reply'));
      expect(replyPressed, isTrue);
    });

    testWidgets('calls onShowReplies when show replies button is pressed', (tester) async {
      bool showRepliesPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentCard(
              comment: tComment,
              onShowReplies: () => showRepliesPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show 2 replies'));
      expect(showRepliesPressed, isTrue);
    });

    testWidgets('renders as reply with correct padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentCard(
              comment: tComment,
              isReply: true,
            ),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, equals(const EdgeInsets.only(left: 48.0, right: 16.0, top: 8.0, bottom: 8.0)));
    });

    testWidgets('shows blocked state', (tester) async {
      final blockedComment = tComment.copyWith(isAuthorBlocked: true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentCard(comment: blockedComment),
          ),
        ),
      );

      expect(find.text('You blocked this user'), findsOneWidget);
      expect(find.text('Test Comment Content'), findsNothing);
    });

    testWidgets('has correct avatar structure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommentCard(
              comment: tComment.copyWith(userPfp: 'https://example.com/pfp.jpg'),
            ),
          ),
        ),
      );

      final avatarFinder = find.byKey(Key('comment_card_avatar_${tComment.id}_inkwell'));
      expect(avatarFinder, findsOneWidget);
    });
  });
}
