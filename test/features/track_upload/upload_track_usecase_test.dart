import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/error/failures.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';
import 'package:rythmify/features/track_upload/domain/repositories/upload_track_repository.dart';
import 'package:rythmify/features/track_upload/domain/usecases/upload_track_usecase.dart';

class MockUploadTrackRepository extends Mock implements UploadTrackRepository {}

class FakeTrackDraft extends Fake implements TrackDraft {}

class FakeFile extends Fake implements File {}

class FakeProgressCallback extends Fake {
  void call(double progress) {}
}

TrackDraft _draft({
  String? title = 'Song',
  String? artist = 'Artist',
  String? genre = 'Pop',
  String localAudioPath = '/music/song.mp3',
  Duration duration = const Duration(seconds: 180),
  String? artworkPath,
}) {
  return TrackDraft(
    artistId: 'user-1',
    localAudioPath: localAudioPath,
    duration: duration,
    title: title,
    artist: artist,
    genre: genre,
    localArtworkPath: artworkPath,
  );
}

void main() {
  late MockUploadTrackRepository repository;
  late UploadTrackUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeTrackDraft());
    registerFallbackValue(FakeFile());
    registerFallbackValue(FakeProgressCallback().call);
  });

  setUp(() {
    repository = MockUploadTrackRepository();
    useCase = UploadTrackUseCase(repository, fileExists: (_) => true);
  });

  group('UploadTrackUseCase validation', () {
    test(
      'rejects missing title, artist, genre, audio path, and duration',
      () async {
        final cases = <TrackDraft, String>{
          _draft(title: ''): 'Track title is required.',
          _draft(artist: '   '): 'Artist name is required.',
          _draft(genre: null): 'Please select a genre.',
          _draft(localAudioPath: '  '): 'No audio file selected.',
          _draft(duration: Duration.zero): 'Could not detect audio duration.',
        };

        for (final entry in cases.entries) {
          final result = await useCase(draft: entry.key);
          expect(result.fold((l) => l.message, (_) => ''), entry.value);
        }

        verifyNever(
          () => repository.uploadTrack(
            draft: any(named: 'draft'),
            audioFile: any(named: 'audioFile'),
            artworkFile: any(named: 'artworkFile'),
            onProgress: any(named: 'onProgress'),
          ),
        );
      },
    );

    test('rejects a missing audio file after metadata validation', () async {
      final missingFileUseCase = UploadTrackUseCase(
        repository,
        fileExists: (_) => false,
      );

      final result = await missingFileUseCase(draft: _draft());

      expect(result.fold((l) => l, (_) => null), isA<FileFailure>());
      verifyNever(
        () => repository.uploadTrack(
          draft: any(named: 'draft'),
          audioFile: any(named: 'audioFile'),
          artworkFile: any(named: 'artworkFile'),
          onProgress: any(named: 'onProgress'),
        ),
      );
    });
  });

  group('UploadTrackUseCase upload flow', () {
    test(
      'passes audio/artwork files and progress callback to repository',
      () async {
        final progress = <double>[];
        when(
          () => repository.uploadTrack(
            draft: any(named: 'draft'),
            audioFile: any(named: 'audioFile'),
            artworkFile: any(named: 'artworkFile'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((invocation) async {
          final callback =
              invocation.namedArguments[#onProgress] as void Function(double)?;
          callback?.call(.25);
          callback?.call(1);
          return const Right('track-1');
        });

        final result = await useCase(
          draft: _draft(artworkPath: '/covers/song.jpg'),
          onProgress: progress.add,
        );

        expect(result, const Right('track-1'));
        expect(progress, [.25, 1]);
        verify(
          () => repository.uploadTrack(
            draft: any(named: 'draft'),
            audioFile: any(
              named: 'audioFile',
              that: predicate<File>((file) => file.path == '/music/song.mp3'),
            ),
            artworkFile: any(
              named: 'artworkFile',
              that: predicate<File>((file) => file.path == '/covers/song.jpg'),
            ),
            onProgress: any(named: 'onProgress'),
          ),
        ).called(1);
      },
    );

    test('propagates repository upload failure', () async {
      when(
        () => repository.uploadTrack(
          draft: any(named: 'draft'),
          audioFile: any(named: 'audioFile'),
          artworkFile: any(named: 'artworkFile'),
          onProgress: any(named: 'onProgress'),
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(draft: _draft());

      expect(result, const Left(NetworkFailure()));
    });
  });
}
