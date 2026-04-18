import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/data/datasources/audio_handler.dart';
import 'package:rythmify/features/player/data/repositories/audio_repository_impl.dart';

class MockRythmifyAudioHandler extends Mock implements RythmifyAudioHandler {}

class MockPlaybackEvent extends Mock implements PlaybackEvent {}

void main() {
  late AudioRepositoryImpl repository;
  late MockRythmifyAudioHandler mockHandler;

  late StreamController<PlaybackEvent> playbackEventController;
  late StreamController<Duration> positionController;
  late StreamController<int?> currentIndexController;
  late StreamController<bool> playingController;

  final tTrack = Track(
    id: 'track-1',
    userId: 'user-1',
    title: 'Test Track',
    artist: 'Artist',
    audioUrl: 'http://example.com/audio.mp3',
    duration: const Duration(minutes: 3),
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

    when(() => mockHandler.currentQueue).thenReturn([]);
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
    test('initial state is correct', () {
      expect(repository.currentState, const AppPlayerState());
    });

    test('loadQueue sets loading state and calls handler', () async {
      when(
        () => mockHandler.loadQueue(
          any(),
          initialIndex: any(named: 'initialIndex'),
        ),
      ).thenAnswer((_) async {});

      await repository.loadQueue([tTrack], initialIndex: 0);

      verify(() => mockHandler.loadQueue([tTrack], initialIndex: 0)).called(1);
      expect(repository.currentState.status, PlayerStatus.loading);
    });

    test('play, pause, seek, skip delegate to handler', () async {
      when(() => mockHandler.play()).thenAnswer((_) async {});
      when(() => mockHandler.pause()).thenAnswer((_) async {});
      when(() => mockHandler.seek(any())).thenAnswer((_) async {});
      when(() => mockHandler.skipToNext()).thenAnswer((_) async {});
      when(() => mockHandler.skipToPrevious()).thenAnswer((_) async {});

      await repository.play();
      verify(() => mockHandler.play()).called(1);

      await repository.pause();
      verify(() => mockHandler.pause()).called(1);

      await repository.seek(const Duration(seconds: 10));
      verify(() => mockHandler.seek(const Duration(seconds: 10))).called(1);

      await repository.skipToNext();
      verify(() => mockHandler.skipToNext()).called(1);

      await repository.skipToPrevious();
      verify(() => mockHandler.skipToPrevious()).called(1);
    });

    test('setShuffleMode and setLoopMode update state', () async {
      await repository.setShuffleMode(true);
      expect(repository.currentState.isShuffleModeEnabled, true);

      await repository.setLoopMode('all');
      expect(repository.currentState.loopMode, 'all');
    });

    test(
      'updateTrackInfo updates handler and state if track is current',
      () async {
        when(
          () => mockHandler.updateTrackInfo(any(), any()),
        ).thenAnswer((_) async {});
        when(() => mockHandler.currentQueue).thenReturn([tTrack]);

        // We need to set the current track manually for the test
        // Since it's internal, we simulate it via the index stream
        currentIndexController.add(0);
        await Future.delayed(Duration.zero);

        final updatedTrack = tTrack.copyWith(title: 'Updated Title');
        await repository.updateTrackInfo('track-1', updatedTrack);

        verify(
          () => mockHandler.updateTrackInfo('track-1', updatedTrack),
        ).called(1);
        expect(repository.currentState.currentTrack?.title, 'Updated Title');
      },
    );

    test('positionStream updates position in state', () async {
      positionController.add(const Duration(seconds: 5));
      await Future.delayed(Duration.zero);
      expect(repository.currentState.position, const Duration(seconds: 5));
    });

    test('playingStream updates status in state', () async {
      when(() => mockHandler.processingState).thenReturn(ProcessingState.ready);
      playingController.add(true);
      await Future.delayed(Duration.zero);
      expect(repository.currentState.status, PlayerStatus.playing);

      playingController.add(false);
      await Future.delayed(Duration.zero);
      expect(repository.currentState.status, PlayerStatus.paused);
    });
  });
}
