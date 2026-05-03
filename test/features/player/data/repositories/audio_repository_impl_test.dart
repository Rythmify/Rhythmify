import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythmify/features/player/data/repositories/audio_repository_impl.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import '../data_test_helper.dart';

void main() {
  setUpAll(() {
    registerTestFallbacks();
  });

  late AudioRepositoryImpl repository;
  late MockRythmifyAudioHandler mockHandler;

  late StreamController<PlaybackEvent> playbackEventController;
  late StreamController<Duration> positionController;
  late StreamController<int?> currentIndexController;
  late StreamController<bool> playingController;

  final tTrack = Track(
    id: '1',
    userId: 'u1',
    title: 'Track 1',
    artist: 'Artist 1',
    audioUrl: 'https://example.com/audio.mp3',
    duration: const Duration(seconds: 180),
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockHandler = MockRythmifyAudioHandler();

    playbackEventController = StreamController<PlaybackEvent>.broadcast();
    positionController = StreamController<Duration>.broadcast();
    currentIndexController = StreamController<int?>.broadcast();
    playingController = StreamController<bool>.broadcast();

    when(
      () => mockHandler.playbackEventStream,
    ).thenAnswer((_) => playbackEventController.stream);
    when(
      () => mockHandler.positionStream,
    ).thenAnswer((_) => positionController.stream);
    when(
      () => mockHandler.currentIndexStream,
    ).thenAnswer((_) => currentIndexController.stream);
    when(
      () => mockHandler.playingStream,
    ).thenAnswer((_) => playingController.stream);

    when(() => mockHandler.currentQueue).thenReturn([tTrack]);
    when(() => mockHandler.playing).thenReturn(false);
    when(() => mockHandler.processingState).thenReturn(ProcessingState.idle);

    repository = AudioRepositoryImpl(mockHandler);
  });

  tearDown(() {
    playbackEventController.close();
    positionController.close();
    currentIndexController.close();
    playingController.close();
  });

  group('AudioRepositoryImpl', () {
    test('initial state should be correct', () {
      expect(repository.currentState, const AppPlayerState());
    });

    test('should update position when positionStream emits', () async {
      final tPosition = const Duration(seconds: 10);

      // We expect the playerStateStream to emit a new state
      final future = expectLater(
        repository.playerStateStream,
        emits(
          predicate<AppPlayerState>((state) => state.position == tPosition),
        ),
      );

      positionController.add(tPosition);
      await future;

      expect(repository.currentState.position, tPosition);
    });

    test('should update current track when currentIndexStream emits', () async {
      final tIndex = 0;

      final future = expectLater(
        repository.playerStateStream,
        emits(
          predicate<AppPlayerState>(
            (state) =>
                state.currentTrack == tTrack && state.queueIndex == tIndex,
          ),
        ),
      );

      currentIndexController.add(tIndex);
      await future;

      expect(repository.currentState.currentTrack, tTrack);
      expect(repository.currentState.queueIndex, tIndex);
    });

    test('should update status when playingStream emits', () async {
      when(() => mockHandler.processingState).thenReturn(ProcessingState.ready);

      final future = expectLater(
        repository.playerStateStream,
        emits(
          predicate<AppPlayerState>(
            (state) => state.status == PlayerStatus.playing,
          ),
        ),
      );

      playingController.add(true);
      await future;

      expect(repository.currentState.status, PlayerStatus.playing);
    });

    test(
      'should update status and bufferedPosition when playbackEventStream emits',
      () async {
        final tBufferedPosition = const Duration(seconds: 20);
        final tDuration = const Duration(seconds: 180);

        final event = PlaybackEvent(
          processingState: ProcessingState.buffering,
          bufferedPosition: tBufferedPosition,
          duration: tDuration,
        );

        final future = expectLater(
          repository.playerStateStream,
          emits(
            predicate<AppPlayerState>(
              (state) =>
                  state.status == PlayerStatus.loading &&
                  state.bufferedPosition == tBufferedPosition &&
                  state.duration == tDuration,
            ),
          ),
        );

        playbackEventController.add(event);
        await future;

        expect(repository.currentState.status, PlayerStatus.loading);
        expect(repository.currentState.bufferedPosition, tBufferedPosition);
        expect(repository.currentState.duration, tDuration);
      },
    );

    test('loadQueue should call handler and update queueStream', () async {
      final tracks = [tTrack];
      when(
        () => mockHandler.loadQueue(
          any(),
          initialIndex: any(named: 'initialIndex'),
          initialPosition: any(named: 'initialPosition'),
        ),
      ).thenAnswer((_) async => {});

      final future = expectLater(repository.queueStream, emits(tracks));

      await repository.loadQueue(tracks);
      await future;

      verify(() => mockHandler.loadQueue(tracks)).called(1);
    });

    test('play/pause/seek/skip calls handler', () async {
      when(() => mockHandler.play()).thenAnswer((_) async => {});
      when(() => mockHandler.pause()).thenAnswer((_) async => {});
      when(() => mockHandler.seek(any())).thenAnswer((_) async => {});
      when(() => mockHandler.skipToNext()).thenAnswer((_) async => {});
      when(() => mockHandler.skipToPrevious()).thenAnswer((_) async => {});

      await repository.play();
      verify(() => mockHandler.play()).called(1);

      await repository.pause();
      verify(() => mockHandler.pause()).called(1);

      await repository.seek(const Duration(seconds: 5));
      verify(() => mockHandler.seek(const Duration(seconds: 5))).called(1);

      await repository.skipToNext();
      verify(() => mockHandler.skipToNext()).called(1);

      await repository.skipToPrevious();
      verify(() => mockHandler.skipToPrevious()).called(1);
    });

    test('appendTracks should call handler and update queueStream', () async {
      final tracks = [tTrack];
      when(() => mockHandler.appendTracks(any())).thenAnswer((_) async => {});
      when(() => mockHandler.currentQueue).thenReturn([tTrack, tTrack]);

      final future = expectLater(
        repository.queueStream,
        emits([tTrack, tTrack]),
      );

      await repository.appendTracks(tracks);
      await future;

      verify(() => mockHandler.appendTracks(tracks)).called(1);
    });

    test('setShuffleMode/setLoopMode update state', () async {
      final future = expectLater(
        repository.playerStateStream,
        emits(
          predicate<AppPlayerState>(
            (state) => state.isShuffleModeEnabled == true,
          ),
        ),
      );
      await repository.setShuffleMode(true);
      await future;
      expect(repository.currentState.isShuffleModeEnabled, true);

      final future2 = expectLater(
        repository.playerStateStream,
        emits(predicate<AppPlayerState>((state) => state.loopMode == 'all')),
      );
      await repository.setLoopMode('all');
      await future2;
      expect(repository.currentState.loopMode, 'all');
    });

    test(
      'updateTrackInfo updates handler and state if current track',
      () async {
        final updatedTrack = tTrack.copyWith(title: 'Updated Title');
        when(
          () => mockHandler.updateTrackInfo(any(), any()),
        ).thenAnswer((_) async => {});
        when(() => mockHandler.currentQueue).thenReturn([updatedTrack]);

        // Set current track first
        currentIndexController.add(0);

        await repository.updateTrackInfo('1', updatedTrack);

        verify(() => mockHandler.updateTrackInfo('1', updatedTrack)).called(1);
        expect(repository.currentState.currentTrack?.title, 'Updated Title');
      },
    );
  });
}
