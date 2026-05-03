import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/entities/queue_state.dart';
import 'package:rythmify/features/player/domain/entities/queue_item.dart';
import 'package:rythmify/features/player/presentation/providers/queue_provider.dart';
import 'package:rythmify/features/player/presentation/pages/queue_screen.dart';
import '../presentation_test_helper.dart';

class MockQueueNotifier extends Notifier<AppQueueState>
    with Mock
    implements QueueNotifier {}

void main() {
  late MockQueueNotifier mockQueueNotifier;

  setUpAll(() {
    registerPlayerFallbackValues();
  });

  setUp(() {
    mockQueueNotifier = MockQueueNotifier();
  });

  Widget createWidget({required AppQueueState state}) {
    return ProviderScope(
      overrides: [
        queueStateProvider.overrideWith(
          () => MockQueueNotifierWrapper(state, mockQueueNotifier),
        ),
      ],
      child: const MaterialApp(home: QueueScreen()),
    );
  }

  group('QueueScreen', () {
    testWidgets('renders empty state when queue is empty', (tester) async {
      await tester.pumpWidget(createWidget(state: const AppQueueState()));
      expect(find.text('Queue is empty'), findsOneWidget);
    });

    testWidgets('renders sections when queue is not empty', (tester) async {
      final currentItem = QueueItem(track: testTrack, queueItemId: 'current');
      final historyItem = QueueItem(
        track: testTrack.copyWith(id: 'history', title: 'History Track'),
        queueItemId: 'history',
      );
      final upcomingItem = QueueItem(
        track: testTrack.copyWith(id: 'upcoming', title: 'Upcoming Track'),
        queueItemId: 'upcoming',
      );

      final state = AppQueueState(
        currentTrack: currentItem,
        history: [historyItem],
        upcomingTracks: [upcomingItem],
      );

      await tester.pumpWidget(createWidget(state: state));

      expect(find.text('Recently Played'), findsOneWidget);
      expect(find.text('Now Playing'), findsOneWidget);
      expect(find.text('Next Up'), findsOneWidget);

      expect(find.text('History Track'), findsOneWidget);
      expect(find.text(testTrack.title), findsOneWidget);
      expect(find.text('Upcoming Track'), findsOneWidget);
    });

    testWidgets('calls toggleShuffle when shuffle button is pressed', (
      tester,
    ) async {
      final state = AppQueueState(
        currentTrack: QueueItem(track: testTrack, queueItemId: 'current'),
      );

      when(() => mockQueueNotifier.toggleShuffle()).thenReturn(null);

      await tester.pumpWidget(createWidget(state: state));

      await tester.tap(
        find.byKey(const Key('player_queue_shuffle_icon_button')),
      );

      verify(() => mockQueueNotifier.toggleShuffle()).called(1);
    });

    testWidgets('calls playFromQueue when upcoming track is tapped', (
      tester,
    ) async {
      final upcomingItem = QueueItem(
        track: testTrack.copyWith(id: 'upcoming'),
        queueItemId: 'upcoming',
      );
      final state = AppQueueState(
        currentTrack: QueueItem(track: testTrack, queueItemId: 'current'),
        upcomingTracks: [upcomingItem],
      );

      when(() => mockQueueNotifier.playFromQueue(any())).thenReturn(null);

      await tester.pumpWidget(createWidget(state: state));

      await tester.tap(
        find.text('Test Track').last,
      ); // Tapping the upcoming one

      verify(() => mockQueueNotifier.playFromQueue(0)).called(1);
    });
  });
}

class MockQueueNotifierWrapper extends QueueNotifier {
  final AppQueueState _state;
  final MockQueueNotifier _mock;

  MockQueueNotifierWrapper(this._state, this._mock);

  @override
  AppQueueState build() => _state;

  @override
  void toggleShuffle() => _mock.toggleShuffle();

  @override
  void playFromQueue(int index) => _mock.playFromQueue(index);

  @override
  void reorder(int oldIndex, int newIndex) => _mock.reorder(oldIndex, newIndex);
}
