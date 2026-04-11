import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/track/data/datasources/track_local_data_source.dart';
import 'package:rythmify/features/track/data/repositories/mock_track_repository_impl.dart';

class MockTrackLocalDataSource extends Mock implements TrackLocalDataSource {}

void main() {
  late MockTrackRepositoryImpl repository;
  late MockTrackLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockTrackLocalDataSource();
    repository = MockTrackRepositoryImpl(mockLocalDataSource);
  });

  group('MockTrackRepositoryImpl', () {
    test('getTrackDetails returns Track from local data', () async {
      final tJsonList = [
        {
          'id': 'track-123',
          'userId': 'user-789',
          'title': 'Test Track',
          'artist': 'Artist',
          'audioUrl': 'http://audio.mp3',
          'duration': 180000,
          'createdAt': '2023-10-15T10:00:00.000Z',
        }
      ];
      when(() => mockLocalDataSource.getFullTracks())
          .thenAnswer((_) async => tJsonList);

      final result = await repository.getTrackDetails('track-123');

      expect(result, isA<Track>());
      expect(result.id, 'track-123');
    });

    test('getTracks returns list of Tracks', () async {
      final tJsonList = [
        {
          'id': 'track-123',
          'userId': 'user-789',
          'title': 'Test Track',
          'artist': 'Artist',
          'audioUrl': 'http://audio.mp3',
          'duration': 180000,
          'createdAt': '2023-10-15T10:00:00.000Z',
        }
      ];
      when(() => mockLocalDataSource.getSummaryTracks())
          .thenAnswer((_) async => tJsonList);

      final result = await repository.getTracks();

      expect(result.length, 1);
      expect(result.first.id, 'track-123');
    });

    test('getWaveform returns list of doubles', () async {
      final tResponse = {
        'data': {
          'peaks': [0.1, 0.5, 1, 0.2]
        }
      };
      when(() => mockLocalDataSource.getWaveform(any()))
          .thenAnswer((_) async => tResponse);

      final result = await repository.getWaveform('track-123');

      expect(result, [0.1, 0.5, 1.0, 0.2]);
    });

    test('getTags returns mapped tags', () async {
      final tResponse = {
        'data': {
          'items': [
            {'id': 't1', 'name': 'Pop'},
          ]
        }
      };
      when(() => mockLocalDataSource.getTags())
          .thenAnswer((_) async => tResponse);

      final result = await repository.getTags();

      expect(result, {'t1': 'Pop'});
    });
  });
}
