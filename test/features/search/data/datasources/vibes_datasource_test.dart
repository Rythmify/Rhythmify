import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/search/data/datasources/vibes_mock_datasource.dart';
import 'package:rythmify/features/search/data/datasources/vibes_remote_datasource.dart';

void main() {
  group('VibesRemoteSourceImpl', () {
    late Dio dio;
    late String? requestedPath;

    setUp(() {
      requestedPath = null;
      dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requestedPath = options.path;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    {'id': 'rock', 'name': 'Rock'},
                    {'id': 'jazz', 'name': 'Jazz'},
                  ],
                },
              ),
            );
          },
        ),
      );
    });

    test('fetches genres and parses vibe categories', () async {
      final source = VibesRemoteSourceImpl(dio: dio);

      final vibes = await source.getVibes();

      expect(requestedPath, '/genres');
      expect(vibes, hasLength(2));
      expect(vibes.first.id, 'rock');
      expect(vibes.last.title, 'Jazz');
    });

    test('propagates DioException from failed request', () async {
      dio.interceptors.clear();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) => handler.reject(
            DioException(requestOptions: options, message: 'Network error'),
          ),
        ),
      );

      final source = VibesRemoteSourceImpl(dio: dio);

      expect(source.getVibes, throwsA(isA<DioException>()));
    });
  });

  group('VibesRemoteSourceMock', () {
    test('returns hardcoded vibes with layout metadata', () async {
      final source = VibesRemoteSourceMock();

      final vibes = await source.getVibes();

      expect(vibes, hasLength(8));
      expect(vibes.first.id, 'hiphop');
      expect(vibes.first.title, 'Hip Hop & Rap');
      expect(vibes.first.height, 150);
    });
  });
}
