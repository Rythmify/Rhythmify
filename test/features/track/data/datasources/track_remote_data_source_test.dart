import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:rythmify/core/network/api_client.dart';
import 'package:rythmify/features/track/data/datasources/track_remote_data_source.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late TrackRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    dataSource = TrackRemoteDataSourceImpl(mockApiClient);
  });

  group('TrackRemoteDataSourceImpl', () {
    test('getTrackDetails performs GET request and returns map', () async {
      final tResponse = {'id': 'track-123', 'title': 'Test'};
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: tResponse,
          statusCode: 200,
        ),
      );

      final result = await dataSource.getTrackDetails('track-123');

      expect(result, tResponse);
      verify(() => mockDio.get('/tracks/track-123')).called(1);
    });

    test(
      'getTracks performs GET request and returns list when wrapped in data',
      () async {
        final tResponse = {
          'data': [
            {'id': 'track-1'},
            {'id': 'track-2'},
          ],
        };
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: tResponse,
            statusCode: 200,
          ),
        );

        final result = await dataSource.getTracks();

        expect(result.length, 2);
        verify(() => mockDio.get('/tracks')).called(1);
      },
    );

    test('getTracks performs GET request and returns list directly', () async {
      final tResponse = [
        {'id': 'track-1'},
      ];
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: tResponse,
          statusCode: 200,
        ),
      );

      final result = await dataSource.getTracks();

      expect(result.length, 1);
      verify(() => mockDio.get('/tracks')).called(1);
    });

    test('getWaveform performs GET request and returns map', () async {
      final tResponse = {
        'data': {
          'peaks': [0.1, 0.2],
        },
      };
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: tResponse,
          statusCode: 200,
        ),
      );

      final result = await dataSource.getWaveform('track-123');

      expect(result, tResponse);
      verify(() => mockDio.get('/tracks/track-123/waveform')).called(1);
    });

    test('getTags performs GET request and returns map', () async {
      final tResponse = {
        'data': {
          'items': [
            {'id': 't1', 'name': 'Pop'},
          ],
        },
      };
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: tResponse,
          statusCode: 200,
        ),
      );

      final result = await dataSource.getTags();

      expect(result, tResponse);
      verify(() => mockDio.get('/tags')).called(1);
    });
  });
}
