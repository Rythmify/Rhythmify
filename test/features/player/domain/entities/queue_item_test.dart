import 'package:flutter_test/flutter_test.dart';
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

  group('QueueItem', () {
    test('should support value equality', () {
      final item1 = QueueItem(track: tTrack, queueItemId: 'qi1');
      final item2 = QueueItem(track: tTrack, queueItemId: 'qi1');
      expect(item1, item2);
    });

    test('copyWith should return a copy with updated values', () {
      final item = QueueItem(track: tTrack, queueItemId: 'qi1');
      final updatedItem = item.copyWith(
        queueBucket: 'next_up',
        isRecommended: true,
      );

      expect(updatedItem.queueBucket, 'next_up');
      expect(updatedItem.isRecommended, true);
      expect(updatedItem.queueItemId, 'qi1');
    });

    test('fromJson should return a valid model', () {
      final Map<String, dynamic> jsonMap = {
        'id': '1',
        'user_id': 'u1',
        'title': 'Test Track',
        'artist': 'Test Artist',
        'audio_url': 'https://test.com/audio.mp3',
        'duration': 180,
        'created_at': '2023-01-01T00:00:00.000',
        'queue_item_id': 'qi1',
        'queue_bucket': 'next_up',
        'source_type': 'album',
        'source_id': 'a1',
        'is_recommended': true,
      };

      final result = QueueItem.fromJson(jsonMap);

      expect(result.track.id, '1');
      expect(result.queueItemId, 'qi1');
      expect(result.queueBucket, 'next_up');
      expect(result.sourceType, 'album');
      expect(result.sourceId, 'a1');
      expect(result.isRecommended, true);
    });

    test('toJson should return a JSON map containing proper data', () {
      final item = QueueItem(
        track: tTrack,
        queueItemId: 'qi1',
        queueBucket: 'next_up',
        sourceType: 'album',
        sourceId: 'a1',
        isRecommended: true,
      );

      final result = item.toJson();

      expect(result['id'], '1');
      expect(result['queue_item_id'], 'qi1');
      expect(result['queue_bucket'], 'next_up');
      expect(result['source_type'], 'album');
      expect(result['source_id'], 'a1');
      expect(result['is_recommended'], true);
    });
  });
}
