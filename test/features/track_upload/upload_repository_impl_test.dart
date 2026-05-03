import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/error/failures.dart';
import 'package:rythmify/features/track_upload/data/datasources/upload_track_remote_datasource.dart';
import 'package:rythmify/features/track_upload/data/models/upload_response_model.dart';
import 'package:rythmify/features/track_upload/data/repositories/upload_track_repository_impl.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';

class MockUploadTrackRemoteDataSource extends Mock
    implements UploadTrackRemoteDataSource {}

class FakeFile extends Fake implements File {}

class FakeProgressCallback extends Fake {
  void call(double progress) {}
}

TrackDraft _draft({
  String? title = 'Song',
  String? artist = 'Artist',
  String? genre = 'Pop',
}) {
  return TrackDraft(
    artistId: 'user-1',
    localAudioPath: '/tmp/song.mp3',
    duration: const Duration(minutes: 3),
    title: title,
    artist: artist,
    genre: genre,
    description: 'desc',
    caption: 'caption',
    tags: const ['tag'],
    isPublic: false,
    isHidden: true,
    geoRestrictionType: 'include',
    geoRegions: const ['EG'],
  );
}

void main() {
  late MockUploadTrackRemoteDataSource datasource;
  late UploadTrackRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeFile());
    registerFallbackValue(FakeProgressCallback().call);
  });

  setUp(() {
    datasource = MockUploadTrackRemoteDataSource();
    repository = UploadTrackRepositoryImpl(dataSource: datasource);
  });

  group('UploadTrackRepositoryImpl', () {
    test('fetchTags returns datasource tags', () async {
      when(
        () => datasource.fetchTags(),
      ).thenAnswer((_) async => ['pop', 'rock']);

      final result = await repository.fetchTags();
      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []), ['pop', 'rock']);
      verify(() => datasource.fetchTags()).called(1);
    });

    test('fetchTags maps auth failures', () async {
      when(
        () => datasource.fetchTags(),
      ).thenThrow(Exception('AUTH_401: token expired'));

      final result = await repository.fetchTags();

      expect(result.fold((l) => l, (_) => null), isA<AuthFailure>());
    });

    test(
      'uploadTrack forwards metadata/files and returns uploaded track id',
      () async {
        final progress = <double>[];
        when(
          () => datasource.uploadTrack(
            audioFile: any(named: 'audioFile'),
            artworkFile: any(named: 'artworkFile'),
            title: any(named: 'title'),
            artist: any(named: 'artist'),
            genre: any(named: 'genre'),
            description: any(named: 'description'),
            caption: any(named: 'caption'),
            tags: any(named: 'tags'),
            isPublic: any(named: 'isPublic'),
            isHidden: any(named: 'isHidden'),
            geoRestrictionType: any(named: 'geoRestrictionType'),
            geoRegions: any(named: 'geoRegions'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((invocation) async {
          final callback =
              invocation.namedArguments[#onProgress] as void Function(double)?;
          callback?.call(.75);
          return const UploadResponseModel(id: 'track-1', status: 'processing');
        });

        final result = await repository.uploadTrack(
          draft: _draft(),
          audioFile: File('/tmp/song.mp3'),
          artworkFile: File('/tmp/cover.jpg'),
          onProgress: progress.add,
        );

        expect(result, const Right('track-1'));
        expect(progress, [.75]);
        verify(
          () => datasource.uploadTrack(
            audioFile: any(named: 'audioFile'),
            artworkFile: any(named: 'artworkFile'),
            title: 'Song',
            artist: 'Artist',
            genre: 'Pop',
            description: 'desc',
            caption: 'caption',
            tags: ['tag'],
            isPublic: false,
            isHidden: true,
            geoRestrictionType: 'include',
            geoRegions: ['EG'],
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
      },
    );

    test('maps upload error codes to domain failures', () async {
      Future<Failure> uploadFailureFor(Object error) async {
        when(
          () => datasource.uploadTrack(
            audioFile: any(named: 'audioFile'),
            artworkFile: any(named: 'artworkFile'),
            title: any(named: 'title'),
            artist: any(named: 'artist'),
            genre: any(named: 'genre'),
            description: any(named: 'description'),
            caption: any(named: 'caption'),
            tags: any(named: 'tags'),
            isPublic: any(named: 'isPublic'),
            isHidden: any(named: 'isHidden'),
            geoRestrictionType: any(named: 'geoRestrictionType'),
            geoRegions: any(named: 'geoRegions'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenThrow(error);

        final result = await repository.uploadTrack(
          draft: _draft(),
          audioFile: File('/tmp/song.mp3'),
        );
        reset(datasource);
        return result.fold((l) => l, (_) => throw StateError('expected left'));
      }

      expect(
        await uploadFailureFor(Exception('UPLOAD_LIMIT_403')),
        isA<UploadLimitFailure>(),
      );
      expect(
        await uploadFailureFor(Exception('FILE_TOO_LARGE_413')),
        isA<FileTooLargeFailure>(),
      );
      expect(
        await uploadFailureFor(Exception('UNSUPPORTED_FILE_415')),
        isA<UnsupportedFileFailure>(),
      );
      expect(
        await uploadFailureFor(const SocketException('offline')),
        isA<NetworkFailure>(),
      );
      expect(
        await uploadFailureFor(Exception('SERVER_500')),
        isA<UploadFailure>(),
      );
    });
  });
}
