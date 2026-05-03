import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/comments/presentation/providers/floating_comments_provider.dart';
import 'package:rythmify/features/comments/presentation/providers/track_comments_notifier.dart';
import 'package:rythmify/features/comments/presentation/widgets/floating_comment_bar.dart';
import 'package:rythmify/features/player/presentation/providers/player_provider.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';

// Mocks
class MockTrackCommentsNotifier extends Mock implements TrackCommentsNotifier {}

class MockPlayerNotifier extends PlayerNotifier {
  final AppPlayerState _initialState;
  MockPlayerNotifier(this._initialState);
  @override
  AppPlayerState build() => _initialState;
}

void main() {
  late MockTrackCommentsNotifier mockTrackNotifier;

  setUp(() {
    mockTrackNotifier = MockTrackCommentsNotifier();
  });

  final tTrack = Track(
    id: 'track-123',
    userId: 'user-789',
    title: 'Test Track',
    artist: 'Test Artist',
    audioUrl: 'https://example.com/audio.mp3',
    duration: const Duration(seconds: 300),
    createdAt: DateTime.now(),
  );

  group('FloatingCommentBar', () {
    testWidgets('renders emoji when text is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerStateProvider.overrideWith(() => MockPlayerNotifier(AppPlayerState(currentTrack: tTrack))),
            floatingCommentsProvider('track-123').overrideWith((ref) => Future.value(<int, ({String? pfp, String text})>{})),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FloatingCommentBar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('👏'), findsOneWidget);
      expect(find.text('🥺'), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);
    });

    testWidgets('shows send button when text is entered', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerStateProvider.overrideWith(() => MockPlayerNotifier(AppPlayerState(currentTrack: tTrack))),
            floatingCommentsProvider('track-123').overrideWith((ref) => Future.value(<int, ({String? pfp, String text})>{})),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FloatingCommentBar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.text('🔥'), findsNothing);
    });

    testWidgets('appends emoji to text', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerStateProvider.overrideWith(() => MockPlayerNotifier(AppPlayerState(currentTrack: tTrack))),
            floatingCommentsProvider('track-123').overrideWith((ref) => Future.value(<int, ({String? pfp, String text})>{})),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FloatingCommentBar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('🔥'));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, '🔥');
    });

    testWidgets('posts comment on send button tap', (tester) async {
      when(() => mockTrackNotifier.postNewComment(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            playerStateProvider.overrideWith(() => MockPlayerNotifier(AppPlayerState(currentTrack: tTrack, position: const Duration(seconds: 10)))),
            floatingCommentsProvider('track-123').overrideWith((ref) => Future.value(<int, ({String? pfp, String text})>{})),
            trackCommentsProvider('track-123').overrideWith((ref) => mockTrackNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FloatingCommentBar(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Testing');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send));
      verify(() => mockTrackNotifier.postNewComment('Testing', 10)).called(1);
    });
  });
}
