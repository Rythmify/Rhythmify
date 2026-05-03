import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:rythmify/features/player/data/datasources/playback_remote_data_source.dart';
import 'package:rythmify/features/player/data/models/history_record_model.dart';
import '../data_test_helper.dart';

void main() {
  setUpAll(() {
    registerTestFallbacks();
  });

  late PlaybackRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = PlaybackRemoteDataSourceImpl(mockApiClient);
  });

  final tHistoryRecordModel = HistoryRecordModel(
    trackId: '1',
    playedAt: DateTime.parse('2023-01-01T00:00:00.000'),
    durationPlayedSeconds: 120,
  );

  group('initiatePlayback', () {
    test('should return stream_url when the call is successful', () async {
      // arrange
      final response = Response(
        data: <String, dynamic>{
          'data': <String, dynamic>{
            'stream_url': 'https://example.com/stream.mp3',
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      // act
      final result = await dataSource.initiatePlayback('1');

      // assert
      expect(result, 'https://example.com/stream.mp3');
      verify(() => mockDio.post('/tracks/1/play')).called(1);
    });

    test(
      'should return url when stream_url is missing but url is present',
      () async {
        // arrange
        final response = Response(
          data: <String, dynamic>{
            'data': <String, dynamic>{'url': 'https://example.com/stream.mp3'},
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => response);

        // act
        final result = await dataSource.initiatePlayback('1');

        // assert
        expect(result, 'https://example.com/stream.mp3');
      },
    );

    test('should throw an exception when URL is not found', () async {
      // arrange
      final response = Response(
        data: <String, dynamic>{'data': <String, dynamic>{}},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenAnswer((_) async => response);

      // act & assert
      expect(dataSource.initiatePlayback('1'), throwsException);
    });

    test('should rethrow DioException when the call fails', () async {
      // arrange
      when(
        () => mockDio.post(any(), data: any(named: 'data')),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      // act & assert
      expect(
        () => dataSource.initiatePlayback('1'),
        throwsA(isA<DioException>()),
      );
    });
    group('recordHistory', () {
      test('should call post with correct data', () async {
        // arrange
        final response = Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => response);

        // act
        await dataSource.recordHistory(tHistoryRecordModel);

        // assert
        verify(
          () => mockDio.post(
            '/me/listening-history',
            data: tHistoryRecordModel.toJson(),
          ),
        ).called(1);
      });

      test('should silently fail when DioException occurs', () async {
        // arrange
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act & assert (should not throw)
        await dataSource.recordHistory(tHistoryRecordModel);
        verify(
          () => mockDio.post(
            '/me/listening-history',
            data: tHistoryRecordModel.toJson(),
          ),
        ).called(1);
      });
    });

    group('fetchQueueContext', () {
      test('should return data when the call is successful', () async {
        // arrange
        final responseData = {
          'data': {
            'queue': [
              {'id': '1'},
            ],
          },
        };
        final response = Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => response);

        // act
        final result = await dataSource.fetchQueueContext(
          interactionType: 'play',
          sourceType: 'playlist',
          sourceId: 'p1',
        );

        // assert
        expect(result, responseData);
        verify(
          () => mockDio.post(
            '/me/player/queue/context',
            data: {
              'interaction_type': 'play',
              'source_type': 'playlist',
              'source_id': 'p1',
              'target_user_id': null,
            },
          ),
        ).called(1);
      });

      test('should return empty queue when DioException occurs', () async {
        // arrange
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act
        final result = await dataSource.fetchQueueContext(
          interactionType: 'play',
          sourceType: 'playlist',
        );

        // assert
        expect(result, {
          'data': {'queue': []},
        });
      });
    });

    group('syncPlayerState', () {
      test('should call post with correct data', () async {
        // arrange
        final response = Response(
          data: {},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => response);

        final tQueue = [
          {'id': '1'},
        ];

        // act
        await dataSource.syncPlayerState(
          trackId: '1',
          queue: tQueue,
          positionSeconds: 10,
          volume: 0.8,
        );

        // assert
        verify(
          () => mockDio.post(
            '/me/player/state',
            data: {
              'track_id': '1',
              'position_seconds': 10,
              'volume': 0.8,
              'queue': tQueue,
            },
          ),
        ).called(1);
      });

      test('should silently fail when DioException occurs', () async {
        // arrange
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

        // act & assert (should not throw)
        await dataSource.syncPlayerState(trackId: '1', queue: []);
        verify(
          () => mockDio.post('/me/player/state', data: any(named: 'data')),
        ).called(1);
      });
    });
  });
}
