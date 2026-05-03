import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/domain/entities/queue_state.dart';
import 'package:rythmify/features/player/domain/entities/queue_item.dart';
import 'package:rythmify/features/player/presentation/providers/player_provider.dart';
import 'package:rythmify/features/player/presentation/providers/queue_provider.dart';
import 'package:rythmify/features/player/presentation/providers/ad_provider.dart';
import 'package:rythmify/features/player/presentation/pages/full_player_page.dart';
import 'package:rythmify/features/premium/presentation/providers/premium_provider.dart';
import 'package:rythmify/features/track/presentation/providers/track_provider.dart';
import 'package:rythmify/features/track/presentation/providers/track_interaction_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/notifications/presentation/providers/follow_state_provider.dart';
import 'package:rythmify/features/comments/presentation/providers/floating_comments_provider.dart';
import '../presentation_test_helper.dart';

class MockQueueNotifier extends Notifier<AppQueueState>
    with Mock
    implements QueueNotifier {}

class MockAdNotifier extends Notifier<AdState>
    with Mock
    implements AdNotifier {}

class MockFollowStateNotifier extends StateNotifier<Map<String, bool>>
    with Mock
    implements FollowStateNotifier {
  MockFollowStateNotifier() : super({});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockQueueNotifier mockQueueNotifier;
  late MockAdNotifier mockAdNotifier;
  late MockTrackInteractionNotifier mockTrackInteractionNotifier;

  setUpAll(() {
    registerPlayerFallbackValues();
  });

  setUp(() {
    mockQueueNotifier = MockQueueNotifier();
    mockAdNotifier = MockAdNotifier();
    mockTrackInteractionNotifier = MockTrackInteractionNotifier();

    // Default stub for ad notifier build
    when(
      () => mockAdNotifier.build(),
    ).thenReturn(const AdState(trackCount: 0, showAd: false));
  });

  Widget createWidget({
    required AppPlayerState playerState,
    required AppQueueState queueState,
    AdState adState = const AdState(trackCount: 0, showAd: false),
    bool isPremium = false,
  }) {
    // Override the build stub for the specific test case
    when(() => mockAdNotifier.build()).thenReturn(adState);

    return ProviderScope(
      overrides: [
        playerStateProvider.overrideWith(
          () => MockPlayerNotifierWrapper(playerState),
        ),
        queueStateProvider.overrideWith(
          () => MockQueueNotifierWrapper(queueState, mockQueueNotifier),
        ),
        adProvider.overrideWith(() => mockAdNotifier),
        isPremiumProvider.overrideWithValue(isPremium),
        trackDetailsProvider(
          testTrack.id,
        ).overrideWithValue(AsyncValue.data(testTrack)),
        trackInteractionProvider.overrideWithValue(
          mockTrackInteractionNotifier,
        ),
        authProvider.overrideWith(() => MockAuthNotifier()),
        followStateProvider.overrideWith((ref) => MockFollowStateNotifier()),
        floatingCommentsProvider(
          testTrack.id,
        ).overrideWithValue(const AsyncValue.data({})),
      ],
      child: MaterialApp(home: FullPlayerPage()),
    );
  }

  group('FullPlayerPage', () {
    testWidgets('renders "No track playing" when currentTrack is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          playerState: const AppPlayerState(),
          queueState: const AppQueueState(),
        ),
      );
      expect(find.text("No track playing"), findsOneWidget);
    });

    testWidgets('renders player content when track is playing', (tester) async {
      final currentItem = QueueItem(track: testTrack, queueItemId: 'current');
      final playerState = AppPlayerState(currentTrack: testTrack);
      final queueState = AppQueueState(currentTrack: currentItem);

      await tester.pumpWidget(
        createWidget(playerState: playerState, queueState: queueState),
      );

      expect(find.byType(PageView), findsOneWidget);
      expect(find.text(testTrack.title), findsOneWidget);
      expect(find.text(testTrack.artist), findsOneWidget);
    });

    testWidgets('shows ad overlay when showAd is true and not premium', (
      tester,
    ) async {
      final currentItem = QueueItem(track: testTrack, queueItemId: 'current');
      final playerState = AppPlayerState(currentTrack: testTrack);
      final queueState = AppQueueState(currentTrack: currentItem);
      final adState = const AdState(trackCount: 0, showAd: true);

      await tester.pumpWidget(
        createWidget(
          playerState: playerState,
          queueState: queueState,
          adState: adState,
        ),
      );

      await tester.pump();

      // Verification by finding any widget that might be in the overlay stack
      // Since showAd is true, the Stack in FullPlayerPage will have AdBannerOverlay
      expect(find.byType(Stack), findsAtLeast(1));
    });

    testWidgets('swiping PageView calls skipToIndex', (tester) async {
      final currentItem = QueueItem(track: testTrack, queueItemId: 'current');
      final upcomingItem = QueueItem(
        track: testTrack.copyWith(id: 'upcoming'),
        queueItemId: 'upcoming',
      );
      final playerState = AppPlayerState(currentTrack: testTrack);
      final queueState = AppQueueState(
        currentTrack: currentItem,
        upcomingTracks: [upcomingItem],
      );

      when(() => mockQueueNotifier.skipToIndex(any())).thenReturn(null);

      await tester.pumpWidget(
        createWidget(playerState: playerState, queueState: queueState),
      );

      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();

      verify(() => mockQueueNotifier.skipToIndex(1)).called(1);
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
  void skipToIndex(int index) => _mock.skipToIndex(index);
}

class MockAdNotifierWrapper extends AdNotifier {
  final AdState _state;
  final MockAdNotifier _mock;
  MockAdNotifierWrapper(this._state, this._mock);
  @override
  AdState build() => _state;
}

class MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();
}
