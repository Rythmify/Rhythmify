import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/data/repositories/playback_repository_impl.dart';
import 'package:rythmify/features/player/data/models/history_record_model.dart';
import 'package:rythmify/features/player/domain/entities/history_record.dart';
import '../data_test_helper.dart';

void main() {
  late PlaybackRepositoryImpl repository;
  late MockPlaybackRemoteDataSource mockRemoteDataSource;
  late MockPlaybackLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerTestFallbacks();
  });

  setUp(() {
    mockRemoteDataSource = MockPlaybackRemoteDataSource();
    mockLocalDataSource = MockPlaybackLocalDataSource();
    repository = PlaybackRepositoryImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
    );
  });

  final tHistoryRecord = HistoryRecord(
    trackId: '1',
    playedAt: DateTime.parse('2023-01-01T00:00:00.000'),
    durationPlayedSeconds: 120,
  );
  final tHistoryRecordModel = HistoryRecordModel.fromEntity(tHistoryRecord);

  group('initiatePlayback', () {
    test('should return stream URL when remote call is successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.initiatePlayback(any()),
      ).thenAnswer((_) async => 'https://example.com/stream.mp3');

      // act
      final result = await repository.initiatePlayback('1');

      // assert
      expect(result, 'https://example.com/stream.mp3');
      verify(() => mockRemoteDataSource.initiatePlayback('1')).called(1);
    });

    test('should rethrow exception when remote call fails', () async {
      // arrange
      when(
        () => mockRemoteDataSource.initiatePlayback(any()),
      ).thenThrow(Exception('Failed'));

      // act & assert
      expect(() => repository.initiatePlayback('1'), throwsException);
    });
  });

  group('recordListeningHistory', () {
    test('should call remote data source when successful', () async {
      // arrange
      when(
        () => mockRemoteDataSource.recordHistory(any()),
      ).thenAnswer((_) async => {});

      // act
      await repository.recordListeningHistory(tHistoryRecord);

      // assert
      verify(
        () => mockRemoteDataSource.recordHistory(tHistoryRecordModel),
      ).called(1);
      verifyNever(() => mockLocalDataSource.cacheHistoryRecord(any()));
    });

    test('should cache locally when remote call fails', () async {
      // arrange
      when(
        () => mockRemoteDataSource.recordHistory(any()),
      ).thenThrow(Exception('Network Error'));
      when(
        () => mockLocalDataSource.cacheHistoryRecord(any()),
      ).thenAnswer((_) async => {});

      // act
      await repository.recordListeningHistory(tHistoryRecord);

      // assert
      verify(
        () => mockRemoteDataSource.recordHistory(tHistoryRecordModel),
      ).called(1);
      verify(
        () => mockLocalDataSource.cacheHistoryRecord(tHistoryRecordModel),
      ).called(1);
    });
  });

  group('syncPendingHistory', () {
    test(
      'should sync all pending records and remove them from local storage',
      () async {
        // arrange
        final records = [tHistoryRecordModel];
        when(
          () => mockLocalDataSource.getPendingHistoryRecords(),
        ).thenAnswer((_) async => records);
        when(
          () => mockRemoteDataSource.recordHistory(any()),
        ).thenAnswer((_) async => {});
        when(
          () => mockLocalDataSource.removeHistoryRecords(any()),
        ).thenAnswer((_) async => {});

        // act
        await repository.syncPendingHistory();

        // assert
        verify(
          () => mockRemoteDataSource.recordHistory(tHistoryRecordModel),
        ).called(1);
        verify(
          () => mockLocalDataSource.removeHistoryRecords(records),
        ).called(1);
      },
    );

    test('should stop syncing on first error', () async {
      // arrange
      final records = [tHistoryRecordModel, tHistoryRecordModel];
      when(
        () => mockLocalDataSource.getPendingHistoryRecords(),
      ).thenAnswer((_) async => records);
      when(
        () => mockRemoteDataSource.recordHistory(any()),
      ).thenThrow(Exception('Error'));
      when(
        () => mockLocalDataSource.removeHistoryRecords(any()),
      ).thenAnswer((_) async => {});

      // act
      await repository.syncPendingHistory();

      // assert
      verify(
        () => mockRemoteDataSource.recordHistory(tHistoryRecordModel),
      ).called(1);
      verifyNever(() => mockLocalDataSource.removeHistoryRecords(any()));
    });

    test('should remove only successfully synced records', () async {
      // arrange
      final records = [
        HistoryRecordModel(
          trackId: '1',
          playedAt: DateTime.now(),
          durationPlayedSeconds: 10,
        ),
        HistoryRecordModel(
          trackId: '2',
          playedAt: DateTime.now(),
          durationPlayedSeconds: 10,
        ),
      ];
      when(
        () => mockLocalDataSource.getPendingHistoryRecords(),
      ).thenAnswer((_) async => records);

      when(
        () => mockRemoteDataSource.recordHistory(records[0]),
      ).thenAnswer((_) async => {});
      when(
        () => mockRemoteDataSource.recordHistory(records[1]),
      ).thenThrow(Exception('Error'));

      when(
        () => mockLocalDataSource.removeHistoryRecords(any()),
      ).thenAnswer((_) async => {});

      // act
      await repository.syncPendingHistory();

      // assert
      verify(() => mockRemoteDataSource.recordHistory(records[0])).called(1);
      verify(() => mockRemoteDataSource.recordHistory(records[1])).called(1);
      verify(
        () => mockLocalDataSource.removeHistoryRecords([records[0]]),
      ).called(1);
    });
  });

  group('fetchQueueContext', () {
    test('should call remote data source', () async {
      // arrange
      when(
        () => mockRemoteDataSource.fetchQueueContext(
          interactionType: any(named: 'interactionType'),
          sourceType: any(named: 'sourceType'),
          sourceId: any(named: 'sourceId'),
          targetUserId: any(named: 'targetUserId'),
        ),
      ).thenAnswer((_) async => {'data': {}});

      // act
      await repository.fetchQueueContext(
        interactionType: 'play',
        sourceType: 'playlist',
      );

      // assert
      verify(
        () => mockRemoteDataSource.fetchQueueContext(
          interactionType: 'play',
          sourceType: 'playlist',
        ),
      ).called(1);
    });
  });

  group('syncPlayerState', () {
    test('should call remote data source', () async {
      // arrange
      when(
        () => mockRemoteDataSource.syncPlayerState(
          trackId: any(named: 'trackId'),
          queue: any(named: 'queue'),
          positionSeconds: any(named: 'positionSeconds'),
          volume: any(named: 'volume'),
        ),
      ).thenAnswer((_) async => {});

      // act
      await repository.syncPlayerState(trackId: '1', queue: []);

      // assert
      verify(
        () => mockRemoteDataSource.syncPlayerState(trackId: '1', queue: []),
      ).called(1);
    });
  });
}
