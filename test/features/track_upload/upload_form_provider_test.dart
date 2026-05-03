import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/core/error/failures.dart';
import 'package:rythmify/features/track_upload/data/datasources/upload_track_remote_datasource.dart';
import 'package:rythmify/features/track_upload/domain/entities/track_draft.dart';
import 'package:rythmify/features/track_upload/domain/repositories/upload_track_repository.dart';
import 'package:rythmify/features/track_upload/domain/usecases/upload_track_usecase.dart';
import 'package:rythmify/features/track_upload/presentation/providers/upload_track_provider.dart';

class MockUploadTrackRepository extends Mock implements UploadTrackRepository {}

class MockUploadTrackRemoteDataSource extends Mock
    implements UploadTrackRemoteDataSource {}

class FakeTrackDraft extends Fake implements TrackDraft {}

class FakeFile extends Fake implements File {}

class FakeProgressCallback extends Fake {
  void call(double progress) {}
}

ProviderContainer _container() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

TrackDraft _draft() {
  return TrackDraft(
    artistId: 'user-1',
    localAudioPath: '/music/song.mp3',
    duration: const Duration(minutes: 3),
    title: 'Song',
    artist: 'Artist',
    genre: 'Pop',
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTrackDraft());
    registerFallbackValue(FakeFile());
    registerFallbackValue(FakeProgressCallback().call);
  });

  group('UploadFormState', () {
    test('canSave requires a draft with non-empty title and artist', () {
      expect(const UploadFormState().canSave, isFalse);
      expect(UploadFormState(draft: _draft()).canSave, isTrue);
      expect(
        UploadFormState(draft: _draft().copyWith(title: '  ')).canSave,
        isFalse,
      );
      expect(
        UploadFormState(draft: _draft().copyWith(artist: '')).canSave,
        isFalse,
      );
    });

    test('copyWith preserves error unless explicitly cleared', () {
      const state = UploadFormState(errorMessage: 'failed');

      expect(state.copyWith(currentTab: 1).errorMessage, 'failed');
      expect(state.copyWith(clearError: true).errorMessage, isNull);
    });
  });

  group('UploadFormNotifier draft editing', () {
    test(
      'initDraft derives title from filename and starts audio uploading state',
      () {
        final container = _container();
        final notifier = container.read(uploadFormProvider.notifier);

        notifier.initDraft(
          artistId: 'artist-1',
          artistName: 'Artist',
          localAudioPath: '/music/night.drive.wav',
          duration: const Duration(seconds: 210),
          fileName: 'night.drive.wav',
        );

        final draft = container.read(uploadFormProvider).draft!;
        expect(draft.artistId, 'artist-1');
        expect(draft.localAudioPath, '/music/night.drive.wav');
        expect(draft.audioFileName, 'night.drive.wav');
        expect(draft.title, 'night.drive');
        expect(draft.artist, 'Artist');
        expect(draft.audioStatus, UploadStatus.uploading);
        expect(draft.audioUploadProgress, 0);
      },
    );

    test('field setters propagate metadata and visibility to draft', () {
      final container = _container();
      final notifier = container.read(uploadFormProvider.notifier);
      notifier.initDraft(
        artistId: 'artist-1',
        artistName: 'Artist',
        localAudioPath: '/music/song.mp3',
        duration: const Duration(seconds: 180),
        fileName: 'song.mp3',
      );

      notifier
        ..setTitle('New Title')
        ..setArtist('New Artist')
        ..setGenre('House')
        ..setDescription('desc')
        ..setCaption('caption')
        ..setIsPublic(false)
        ..setIsHidden(true)
        ..setArtwork('/covers/cover.jpg')
        ..setGeoRestrictionType('include')
        ..toggleGeoRegion('EG')
        ..toggleGeoRegion('US')
        ..toggleGeoRegion('US')
        ..setUploadProgress(.5);

      final draft = container.read(uploadFormProvider).draft!;
      expect(draft.title, 'New Title');
      expect(draft.artist, 'New Artist');
      expect(draft.genre, 'House');
      expect(draft.description, 'desc');
      expect(draft.caption, 'caption');
      expect(draft.isPublic, isFalse);
      expect(draft.isHidden, isTrue);
      expect(draft.localArtworkPath, '/covers/cover.jpg');
      expect(draft.geoRestrictionType, 'include');
      expect(draft.geoRegions, ['EG']);
      expect(draft.status, UploadStatus.uploading);
      expect(draft.uploadProgress, .5);

      notifier.setUploadProgress(1);
      expect(
        container.read(uploadFormProvider).draft!.status,
        UploadStatus.success,
      );
    });

    test('tag operations prevent duplicates and support removal', () {
      final container = _container();
      final notifier = container.read(uploadFormProvider.notifier);
      notifier.initDraft(
        artistId: 'artist-1',
        artistName: 'Artist',
        localAudioPath: '/music/song.mp3',
        duration: const Duration(seconds: 180),
        fileName: 'song.mp3',
      );

      notifier
        ..setAvailableTags(['pop', 'club'])
        ..addTag('pop')
        ..addTag('pop')
        ..addTag('club')
        ..removeTag('pop')
        ..setTab(2);

      final state = container.read(uploadFormProvider);
      expect(state.availableTags, ['pop', 'club']);
      expect(state.draft!.tags, ['club']);
      expect(state.currentTab, 2);
    });

    test(
      'fetchTags and fetchGenres populate options and ignore failures',
      () async {
        final datasource = MockUploadTrackRemoteDataSource();
        when(
          () => datasource.fetchTags(),
        ).thenAnswer((_) async => ['pop', 'club']);
        when(
          () => datasource.fetchGenres(),
        ).thenAnswer((_) async => ['Pop', 'House']);

        final container = _container();
        final notifier = container.read(uploadFormProvider.notifier);
        await notifier.fetchTags(null, datasource);
        await notifier.fetchGenres(null, datasource);

        expect(container.read(uploadFormProvider).availableTags, [
          'pop',
          'club',
        ]);
        expect(container.read(uploadFormProvider).availableGenres, [
          'Pop',
          'House',
        ]);

        when(() => datasource.fetchTags()).thenThrow(Exception('tags down'));
        when(
          () => datasource.fetchGenres(),
        ).thenThrow(Exception('genres down'));
        await notifier.fetchTags(null, datasource);
        await notifier.fetchGenres(null, datasource);

        expect(container.read(uploadFormProvider).availableTags, [
          'pop',
          'club',
        ]);
        expect(container.read(uploadFormProvider).availableGenres, [
          'Pop',
          'House',
        ]);
      },
    );

    test('removeArtwork, clearGeoRegions, and reset clear state', () {
      final container = _container();
      final notifier = container.read(uploadFormProvider.notifier);
      notifier.initDraft(
        artistId: 'artist-1',
        artistName: 'Artist',
        localAudioPath: '/music/song.mp3',
        duration: const Duration(seconds: 180),
        fileName: 'song.mp3',
      );

      notifier
        ..setArtwork('/covers/cover.jpg')
        ..toggleGeoRegion('EG')
        ..removeArtwork()
        ..clearGeoRegions();

      expect(
        container.read(uploadFormProvider).draft!.localArtworkPath,
        isNull,
      );
      expect(container.read(uploadFormProvider).draft!.geoRegions, isEmpty);

      notifier.reset();
      expect(container.read(uploadFormProvider).draft, isNull);
    });

    test('startAudioUpload progresses audio state to success', () async {
      final container = _container();
      final notifier = container.read(uploadFormProvider.notifier);
      notifier.initDraft(
        artistId: 'artist-1',
        artistName: 'Artist',
        localAudioPath: '/music/song.mp3',
        duration: const Duration(seconds: 180),
        fileName: 'song.mp3',
      );

      notifier.startAudioUpload();
      await Future<void>.delayed(const Duration(milliseconds: 4300));

      final draft = container.read(uploadFormProvider).draft!;
      expect(draft.audioStatus, UploadStatus.success);
      expect(draft.audioUploadProgress, 1);
    });

    test('initFromTrack maps existing track into update draft', () {
      final container = _container();
      final notifier = container.read(uploadFormProvider.notifier);
      final track = Track(
        id: 'track-1',
        userId: 'artist-1',
        title: 'Existing',
        artist: 'Artist',
        audioUrl: 'https://cdn/audio.mp3',
        duration: const Duration(seconds: 200),
        createdAt: DateTime(2024, 1, 1),
        coverImage: 'https://cdn/cover.jpg',
        genre: 'Pop',
        tags: const ['demo'],
        description: 'desc',
        isPublic: false,
        isHidden: true,
        geoRestrictionType: 'include',
        geoRegions: const ['EG'],
      );

      notifier.initFromTrack(track);

      final draft = container.read(uploadFormProvider).draft!;
      expect(draft.trackId, 'track-1');
      expect(draft.remoteArtworkUrl, 'https://cdn/cover.jpg');
      expect(draft.localAudioPath, '');
      expect(draft.audioStatus, UploadStatus.success);
      expect(draft.isPublic, isFalse);
      expect(draft.isHidden, isTrue);
      expect(draft.geoRegions, ['EG']);
    });
  });

  group('UploadFormNotifier startUpload', () {
    test(
      'transitions uploading progress to success and calls onSuccess',
      () async {
        final repository = MockUploadTrackRepository();
        final useCase = UploadTrackUseCase(repository, fileExists: (_) => true);
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
          callback?.call(.4);
          return const Right('track-1');
        });
        final container = _container();
        final notifier = container.read(uploadFormProvider.notifier);
        notifier.initDraft(
          artistId: 'artist-1',
          artistName: 'Artist',
          localAudioPath: '/music/song.mp3',
          duration: const Duration(seconds: 180),
          fileName: 'song.mp3',
        );
        notifier.setGenre('Pop');
        var successId = '';
        var error = '';

        await notifier.startUpload(
          useCaseOverride: useCase,
          onSuccess: (trackId) => successId = trackId,
          onError: (message) => error = message,
        );

        final draft = container.read(uploadFormProvider).draft!;
        expect(successId, 'track-1');
        expect(error, isEmpty);
        expect(draft.status, UploadStatus.success);
        expect(draft.uploadProgress, 1);
      },
    );

    test(
      'transitions to error and preserves failure message on upload failure',
      () async {
        final repository = MockUploadTrackRepository();
        final useCase = UploadTrackUseCase(repository, fileExists: (_) => true);
        when(
          () => repository.uploadTrack(
            draft: any(named: 'draft'),
            audioFile: any(named: 'audioFile'),
            artworkFile: any(named: 'artworkFile'),
            onProgress: any(named: 'onProgress'),
          ),
        ).thenAnswer((_) async => const Left(UploadLimitFailure()));
        final container = _container();
        final notifier = container.read(uploadFormProvider.notifier);
        notifier.initDraft(
          artistId: 'artist-1',
          artistName: 'Artist',
          localAudioPath: '/music/song.mp3',
          duration: const Duration(seconds: 180),
          fileName: 'song.mp3',
        );
        notifier.setGenre('Pop');
        var error = '';

        await notifier.startUpload(
          useCaseOverride: useCase,
          onSuccess: (_) {},
          onError: (message) => error = message,
        );

        expect(
          container.read(uploadFormProvider).draft!.status,
          UploadStatus.error,
        );
        expect(error, 'Upload limit reached. Try again later.');
      },
    );

    test(
      'reports service unavailable when no ref or use case is supplied',
      () async {
        final container = _container();
        final notifier = container.read(uploadFormProvider.notifier);
        notifier.initDraft(
          artistId: 'artist-1',
          artistName: 'Artist',
          localAudioPath: '/music/song.mp3',
          duration: const Duration(seconds: 180),
          fileName: 'song.mp3',
        );
        var error = '';

        await notifier.startUpload(
          onSuccess: (_) {},
          onError: (message) => error = message,
        );

        expect(
          container.read(uploadFormProvider).draft!.status,
          UploadStatus.error,
        );
        expect(error, 'Upload service unavailable.');
      },
    );

    test('production provider chain resolves upload use case', () {
      final container = _container();
      expect(container.read(uploadUseCaseProvider), isA<UploadTrackUseCase>());
    });
  });

  group('UploadFormNotifier update/delete flows', () {
    test(
      'handleUpdate sends editable metadata and clears loading on success',
      () async {
        final container = _container();
        final notifier = container.read(uploadFormProvider.notifier);
        notifier.initFromTrack(
          Track(
            id: 'track-1',
            userId: 'artist-1',
            title: 'Existing',
            artist: 'Artist',
            audioUrl: 'https://cdn/audio.mp3',
            duration: const Duration(seconds: 200),
            createdAt: DateTime(2024, 1, 1),
            genre: 'Pop',
            tags: const ['demo'],
            isPublic: false,
            isHidden: true,
            geoRestrictionType: 'include',
            geoRegions: const ['EG'],
          ),
        );
        Map<String, dynamic>? sentData;
        var success = false;

        await notifier.handleUpdate(
          updateOverride: (trackId, data) async {
            expect(trackId, 'track-1');
            sentData = data;
          },
          onSuccess: () => success = true,
          onError: (_) {},
        );

        expect(success, isTrue);
        expect(container.read(uploadFormProvider).isLoading, isFalse);
        expect(sentData?['title'], 'Existing');
        expect(sentData?['genre'], 'Pop');
        expect(sentData?['is_public'], isFalse);
        expect(sentData?['geo_regions'], ['EG']);
      },
    );

    test('handleUpdate and handleDelete surface failures', () async {
      final container = _container();
      final notifier = container.read(uploadFormProvider.notifier);
      notifier.initFromTrack(
        Track(
          id: 'track-1',
          userId: 'artist-1',
          title: 'Existing',
          artist: 'Artist',
          audioUrl: 'https://cdn/audio.mp3',
          duration: const Duration(seconds: 200),
          createdAt: DateTime(2024, 1, 1),
        ),
      );
      final errors = <String>[];

      await notifier.handleUpdate(
        updateOverride: (_, __) async => throw Exception('update failed'),
        onSuccess: () {},
        onError: errors.add,
      );
      await notifier.handleDelete(
        deleteOverride: (_) async => throw Exception('delete failed'),
        onSuccess: () {},
        onError: errors.add,
      );

      expect(container.read(uploadFormProvider).isLoading, isFalse);
      expect(errors[0], contains('update failed'));
      expect(errors[1], contains('delete failed'));
    });

    test('handleUpdate and handleDelete report unavailable services', () async {
      final container = _container();
      final notifier = container.read(uploadFormProvider.notifier);
      notifier.initFromTrack(
        Track(
          id: 'track-1',
          userId: 'artist-1',
          title: 'Existing',
          artist: 'Artist',
          audioUrl: 'https://cdn/audio.mp3',
          duration: const Duration(seconds: 200),
          createdAt: DateTime(2024, 1, 1),
        ),
      );
      final errors = <String>[];

      await notifier.handleUpdate(onSuccess: () {}, onError: errors.add);
      await notifier.handleDelete(onSuccess: () {}, onError: errors.add);

      expect(errors, [
        'Update service unavailable.',
        'Delete service unavailable.',
      ]);
    });

    test(
      'handleDelete calls delete service and returns to idle on success',
      () async {
        final container = _container();
        final notifier = container.read(uploadFormProvider.notifier);
        notifier.initFromTrack(
          Track(
            id: 'track-1',
            userId: 'artist-1',
            title: 'Existing',
            artist: 'Artist',
            audioUrl: 'https://cdn/audio.mp3',
            duration: const Duration(seconds: 200),
            createdAt: DateTime(2024, 1, 1),
          ),
        );
        var deleted = '';
        var success = false;

        await notifier.handleDelete(
          deleteOverride: (trackId) async => deleted = trackId,
          onSuccess: () => success = true,
          onError: (_) {},
        );

        expect(deleted, 'track-1');
        expect(success, isTrue);
        expect(container.read(uploadFormProvider).isLoading, isFalse);
      },
    );
  });
}
