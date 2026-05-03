import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/track_upload/data/datasources/upload_track_remote_datasource.dart';

class MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _jsonResponse(
  String path,
  Map<String, dynamic> data,
) {
  return Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: data,
  );
}

void main() {
  late MockDio dio;
  late UploadTrackRemoteDataSource datasource;
  final multipartRequests = <({String path, DioMediaType contentType})>[];

  setUpAll(() {
    registerFallbackValue(Options());
    registerFallbackValue(FormData());
  });

  setUp(() {
    dio = MockDio();
    multipartRequests.clear();
    datasource = UploadTrackRemoteDataSource(
      dio: dio,
      multipartFileFactory: (path, contentType) async {
        multipartRequests.add((path: path, contentType: contentType));
        return MultipartFile.fromBytes([
          1,
          2,
          3,
        ], filename: path.split('/').last);
      },
    );
  });

  group('UploadTrackRemoteDataSource taxonomy calls', () {
    test('default constructor is available for production wiring', () {
      expect(UploadTrackRemoteDataSource(), isA<UploadTrackRemoteDataSource>());
    });

    test(
      'fetchTags parses deployed list shape with strings and maps',
      () async {
        when(() => dio.get('/tags')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/tags'),
            data: {
              'data': [
                'ambient',
                {'name': 'club'},
                {'name': ''},
                42,
              ],
            },
          ),
        );

        final result = await datasource.fetchTags();

        expect(result, ['ambient', 'club']);
        verify(() => dio.get('/tags')).called(1);
      },
    );

    test('fetchTags parses legacy items shape', () async {
      when(() => dio.get('/tags')).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/tags'),
          data: {
            'data': {
              'items': [
                {'name': 'indie'},
              ],
            },
          },
        ),
      );

      expect(await datasource.fetchTags(), ['indie']);
    });

    test(
      'fetchGenres parses both deployed and legacy response shapes',
      () async {
        when(() => dio.get('/genres')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/genres'),
            data: {
              'data': [
                {'name': 'Pop'},
                {'name': ''},
                {'id': 'missing-name'},
              ],
            },
          ),
        );

        expect(await datasource.fetchGenres(), ['Pop']);

        when(() => dio.get('/genres')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/genres'),
            data: {
              'data': {
                'items': [
                  {'name': 'House'},
                ],
              },
            },
          ),
        );

        expect(await datasource.fetchGenres(), ['House']);
      },
    );

    test('maps taxonomy Dio errors to coded exceptions', () async {
      when(() => dio.get('/tags')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/tags'),
          response: Response(
            requestOptions: RequestOptions(path: '/tags'),
            statusCode: 401,
            data: {
              'error': {'message': 'login required'},
            },
          ),
        ),
      );

      expect(
        () => datasource.fetchTags(),
        throwsA(predicate((e) => e.toString().contains('AUTH_401'))),
      );
    });

    test('fetchGenres maps Dio failures to coded exceptions', () async {
      when(() => dio.get('/genres')).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/genres'),
          response: Response(
            requestOptions: RequestOptions(path: '/genres'),
            statusCode: 429,
            data: {'message': 'slow down'},
          ),
        ),
      );

      expect(
        () => datasource.fetchGenres(),
        throwsA(predicate((e) => e.toString().contains('RATE_LIMIT_429'))),
      );
    });
  });

  group('UploadTrackRemoteDataSource uploadTrack', () {
    test(
      'builds multipart fields, repeats arrays, and reports progress',
      () async {
        FormData? sentForm;
        final progress = <double>[];
        when(
          () => dio.post(
            '/tracks',
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenAnswer((invocation) async {
          sentForm = invocation.namedArguments[#data] as FormData;
          final callback =
              invocation.namedArguments[#onSendProgress] as ProgressCallback?;
          callback?.call(50, 100);
          return _jsonResponse('/tracks', {
            'track': {'id': 'track-1', 'status': 'processing'},
          });
        });

        final result = await datasource.uploadTrack(
          audioFile: File('/tmp/song.wav'),
          artworkFile: File('/tmp/cover.png'),
          title: 'Song',
          artist: 'Artist',
          genre: 'Pop',
          description: 'Description',
          caption: 'Caption',
          tags: const ['tag-a', 'tag-b'],
          isPublic: false,
          isHidden: true,
          geoRestrictionType: 'include',
          geoRegions: const ['EG', 'US'],
          onProgress: progress.add,
        );

        expect(result.id, 'track-1');
        expect(result.status, 'processing');
        expect(progress, [.5]);
        expect(multipartRequests.map((r) => r.path), [
          '/tmp/song.wav',
          '/tmp/cover.png',
        ]);

        final fields = Map.fromEntries(sentForm!.fields);
        expect(fields['title'], 'Song');
        expect(fields['artists'], 'Artist');
        expect(fields['genre'], 'Pop');
        expect(fields['is_public'], 'false');
        expect(fields['is_hidden'], 'true');
        expect(fields['description'], 'Description');
        expect(fields['geo_restriction_type'], 'include');
        expect(
          sentForm!.fields.where((e) => e.key == 'tags[]').map((e) => e.value),
          ['tag-a', 'tag-b'],
        );
        expect(
          sentForm!.fields
              .where((e) => e.key == 'geo_regions[]')
              .map((e) => e.value),
          ['EG', 'US'],
        );
        expect(sentForm!.files.map((f) => f.key), [
          'audio_file',
          'cover_image',
        ]);
      },
    );

    test('omits optional fields and artwork when they are empty', () async {
      FormData? sentForm;
      when(
        () => dio.post(
          '/tracks',
          data: any(named: 'data'),
          options: any(named: 'options'),
          onSendProgress: any(named: 'onSendProgress'),
        ),
      ).thenAnswer((invocation) async {
        sentForm = invocation.namedArguments[#data] as FormData;
        return _jsonResponse('/tracks', {'id': 'track-2', 'status': 'ready'});
      });

      await datasource.uploadTrack(
        audioFile: File('/tmp/song.mp3'),
        title: 'Song',
        artist: 'Artist',
        genre: '',
        description: '',
        tags: const [],
        isPublic: true,
      );

      final fields = Map.fromEntries(sentForm!.fields);
      expect(fields.containsKey('description'), isFalse);
      expect(fields.containsKey('geo_restriction_type'), isFalse);
      expect(sentForm!.files.map((f) => f.key), ['audio_file']);
    });

    test(
      'maps upload HTTP failures to coded exceptions for repository',
      () async {
        when(
          () => dio.post(
            '/tracks',
            data: any(named: 'data'),
            options: any(named: 'options'),
            onSendProgress: any(named: 'onSendProgress'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/tracks'),
            response: Response(
              requestOptions: RequestOptions(path: '/tracks'),
              statusCode: 413,
              data: {'message': 'too big'},
            ),
          ),
        );

        expect(
          () => datasource.uploadTrack(
            audioFile: File('/tmp/song.mp3'),
            title: 'Song',
            artist: 'Artist',
            genre: 'Pop',
            tags: const [],
            isPublic: true,
          ),
          throwsA(
            predicate((e) => e.toString().contains('FILE_TOO_LARGE_413')),
          ),
        );
      },
    );

    test(
      'maps upload auth, unsupported media, rate, and unknown errors',
      () async {
        Future<String> errorFor(int? statusCode) async {
          when(
            () => dio.post(
              '/tracks',
              data: any(named: 'data'),
              options: any(named: 'options'),
              onSendProgress: any(named: 'onSendProgress'),
            ),
          ).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/tracks'),
              response: statusCode == null
                  ? null
                  : Response(
                      requestOptions: RequestOptions(path: '/tracks'),
                      statusCode: statusCode,
                      data: {
                        'error': {'message': 'server said no'},
                      },
                    ),
              message: 'socket closed',
            ),
          );
          try {
            await datasource.uploadTrack(
              audioFile: File('/tmp/song.mp3'),
              title: 'Song',
              artist: 'Artist',
              genre: 'Pop',
              tags: const [],
              isPublic: true,
            );
            return '';
          } catch (e) {
            reset(dio);
            return e.toString();
          }
        }

        expect(await errorFor(403), contains('UPLOAD_LIMIT_403'));
        expect(await errorFor(415), contains('UNSUPPORTED_FILE_415'));
        expect(await errorFor(429), contains('RATE_LIMIT_429'));
        expect(await errorFor(null), contains('SERVER_UNKNOWN'));
      },
    );
  });
}
