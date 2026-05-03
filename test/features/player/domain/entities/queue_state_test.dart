import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/player/domain/entities/queue_state.dart';
import 'package:rythmify/features/player/domain/entities/queue_item.dart';
import 'package:rythmify/core/domain/entities/track.dart';

void main() {
  final tTrack = Track(
    id: '1',
    userId: 'u1',
    title: 'Test Track',
    artist: 'Test Artist',
    audioUrl: 'https://test.com/audio.mp3',
    duration: const Duration(minutes: 3),
    createdAt: DateTime(2023, 1, 1),
  );

  final tQueueItem = QueueItem(track: tTrack, queueItemId: 'qi1');

  group('QueueContext', () {
    test('should support value equality', () {
      expect(
        const QueueContext(type: QueueSource.playlist, sourceId: 'p1'),
        const QueueContext(type: QueueSource.playlist, sourceId: 'p1'),
      );
    });
  });

  group('AppQueueState', () {
    test('should support value equality', () {
      expect(const AppQueueState(), const AppQueueState());
    });

    test('copyWith should return a copy with updated values', () {
      const state = AppQueueState();
      final updatedState = state.copyWith(
        currentTrack: tQueueItem,
        isShuffled: true,
        isLoadingRecommendations: true,
      );

      expect(updatedState.currentTrack, tQueueItem);
      expect(updatedState.isShuffled, true);
      expect(updatedState.isLoadingRecommendations, true);
    });

    test('props should contain all fields', () {
      const context = QueueContext(type: QueueSource.playlist, sourceId: 'p1');
      final state = AppQueueState(
        context: context,
        history: [tQueueItem],
        currentTrack: tQueueItem,
        upcomingTracks: [tQueueItem],
        unShuffledUpcomingTracks: [tQueueItem],
        isShuffled: true,
        hasMore: true,
        currentPage: 2,
        isLoadingRecommendations: true,
      );

      expect(state.props, [
        context,
        [tQueueItem],
        tQueueItem,
        [tQueueItem],
        [tQueueItem],
        true,
        true,
        2,
        true,
      ]);
    });
  });
}
