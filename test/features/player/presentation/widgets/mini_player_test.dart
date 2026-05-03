import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/presentation/providers/player_provider.dart';
import 'package:rythmify/features/player/presentation/providers/queue_provider.dart';
import 'package:rythmify/features/player/presentation/widgets/mini_player.dart';
import 'package:rythmify/features/track/presentation/providers/track_interaction_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/notifications/presentation/providers/follow_state_provider.dart';
import 'package:rythmify/features/player/domain/entities/queue_state.dart';
import '../presentation_test_helper.dart';

class MockQueueNotifier extends Notifier<AppQueueState>
    with Mock
    implements QueueNotifier {}

class MockFollowStateNotifier extends StateNotifier<Map<String, bool>>
    with Mock
    implements FollowStateNotifier {
  MockFollowStateNotifier() : super({});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockTrackInteractionNotifier mockTrackInteractionNotifier;
  late MockQueueNotifier mockQueueNotifier;

  setUpAll(() {
    registerPlayerFallbackValues();
  });

  setUp(() {
    mockTrackInteractionNotifier = MockTrackInteractionNotifier();
    mockQueueNotifier = MockQueueNotifier();

    // Stubs for void methods
    when(() => mockQueueNotifier.nextTrack()).thenReturn(null);
    when(() => mockQueueNotifier.previousTrack()).thenReturn(null);
  });

  Widget createWidget({
    required AppPlayerState playerState,
    VoidCallback? onTap,
  }) {
    return ProviderScope(
      overrides: [
        playerStateProvider.overrideWith(
          () => MockPlayerNotifierWrapper(playerState),
        ),
        queueStateProvider.overrideWith(
          () => MockQueueNotifierWrapper(
            const AppQueueState(),
            mockQueueNotifier,
          ),
        ),
        trackInteractionProvider.overrideWithValue(
          mockTrackInteractionNotifier,
        ),
        authProvider.overrideWith(() => MockAuthNotifier()),
        followStateProvider.overrideWith((ref) => MockFollowStateNotifier()),
      ],
      child: MaterialApp(
        home: Scaffold(body: MiniPlayer(onTap: onTap)),
      ),
    );
  }

  group('MiniPlayer', () {
    testWidgets('renders nothing when currentTrack is null', (tester) async {
      await tester.pumpWidget(
        createWidget(playerState: const AppPlayerState()),
      );
      expect(find.byType(MiniPlayer), findsOneWidget);
      expect(
        find.byKey(const Key('player_mini_player_gesture_detector')),
        findsNothing,
      );
    });

    testWidgets('renders track info when currentTrack is not null', (
      tester,
    ) async {
      final playerState = AppPlayerState(currentTrack: testTrack);
      await tester.pumpWidget(createWidget(playerState: playerState));

      expect(find.text(testTrack.title), findsOneWidget);
      expect(find.text(testTrack.artist), findsOneWidget);
    });

    testWidgets('triggers onTap when tapped', (tester) async {
      bool tapped = false;
      final playerState = AppPlayerState(currentTrack: testTrack);
      await tester.pumpWidget(
        createWidget(playerState: playerState, onTap: () => tapped = true),
      );

      await tester.tap(
        find.byKey(const Key('player_mini_player_gesture_detector')),
      );
      expect(tapped, true);
    });

    testWidgets('calls nextTrack on swipe left', (tester) async {
      final playerState = AppPlayerState(currentTrack: testTrack);

      await tester.pumpWidget(createWidget(playerState: playerState));

      // Use flick for better gesture detection
      await tester.fling(
        find.byKey(const Key('player_mini_player_gesture_detector')),
        const Offset(-1000, 0),
        3000,
      );
      await tester.pumpAndSettle();

      verify(() => mockQueueNotifier.nextTrack()).called(1);
    });

    testWidgets('calls previousTrack on swipe right', (tester) async {
      final playerState = AppPlayerState(currentTrack: testTrack);

      await tester.pumpWidget(createWidget(playerState: playerState));

      await tester.fling(
        find.byKey(const Key('player_mini_player_gesture_detector')),
        const Offset(1000, 0),
        3000,
      );
      await tester.pumpAndSettle();

      verify(() => mockQueueNotifier.previousTrack()).called(1);
    });

    testWidgets('calls handleToggleLike when like button pressed', (
      tester,
    ) async {
      final playerState = AppPlayerState(currentTrack: testTrack);
      when(
        () => mockTrackInteractionNotifier.handleToggleLike(
          any(),
          any(),
          currentTrack: any(named: 'currentTrack'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createWidget(playerState: playerState));

      await tester.tap(
        find.byKey(const Key('player_mini_player_like_icon_button')),
      );

      verify(
        () => mockTrackInteractionNotifier.handleToggleLike(
          testTrack.id,
          testTrack.isLiked,
          currentTrack: any(named: 'currentTrack'),
        ),
      ).called(1);
    });
  });
}

class MockPlayerNotifierWrapper extends PlayerNotifier {
  final AppPlayerState _state;
  MockPlayerNotifierWrapper(this._state);
  @override
  AppPlayerState build() => _state;
}

class MockQueueNotifierWrapper extends QueueNotifier {
  final AppQueueState _state;
  final MockQueueNotifier _mock;
  MockQueueNotifierWrapper(this._state, this._mock);
  @override
  AppQueueState build() => _state;
  @override
  void nextTrack() => _mock.nextTrack();
  @override
  void previousTrack() => _mock.previousTrack();
}

class MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();
}
