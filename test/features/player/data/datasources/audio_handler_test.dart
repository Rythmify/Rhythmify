import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:rythmify/features/player/data/datasources/audio_handler.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import '../data_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerTestFallbacks();
  });

  late RythmifyAudioHandler handler;
  late MockAudioPlayer mockPlayer;

  late StreamController<PlaybackEvent> playbackEventController;
  late StreamController<int?> currentIndexController;
  late StreamController<ProcessingState> processingStateController;
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
    mockPlayer = MockAudioPlayer();

    playbackEventController = StreamController<PlaybackEvent>.broadcast();
    currentIndexController = StreamController<int?>.broadcast();
    processingStateController = StreamController<ProcessingState>.broadcast();
    playingController = StreamController<bool>.broadcast();

    when(
      () => mockPlayer.playbackEventStream,
    ).thenAnswer((_) => playbackEventController.stream);
    when(
      () => mockPlayer.currentIndexStream,
    ).thenAnswer((_) => currentIndexController.stream);
    when(
      () => mockPlayer.processingStateStream,
    ).thenAnswer((_) => processingStateController.stream);
    when(
      () => mockPlayer.playingStream,
    ).thenAnswer((_) => playingController.stream);
    when(() => mockPlayer.positionStream).thenAnswer((_) => Stream.empty());
    when(
      () => mockPlayer.bufferedPositionStream,
    ).thenAnswer((_) => Stream.empty());

    when(() => mockPlayer.playing).thenReturn(false);
    when(() => mockPlayer.position).thenReturn(Duration.zero);
    when(() => mockPlayer.bufferedPosition).thenReturn(Duration.zero);
    when(() => mockPlayer.speed).thenReturn(1.0);
    when(() => mockPlayer.processingState).thenReturn(ProcessingState.idle);
    when(() => mockPlayer.currentIndex).thenReturn(0);

    when(
      () => mockPlayer.setAudioSource(
        any(),
        initialIndex: any(named: 'initialIndex'),
        initialPosition: any(named: 'initialPosition'),
        preload: any(named: 'preload'),
      ),
    ).thenAnswer((_) async => const Duration(seconds: 180));

    handler = RythmifyAudioHandler(player: mockPlayer);
  });

  tearDown(() {
    playbackEventController.close();
    currentIndexController.close();
    processingStateController.close();
    playingController.close();
  });

  group('RythmifyAudioHandler', () {
    test('loadQueue should set audio source on player', () async {
      await handler.loadQueue([tTrack], useCache: false);

      verify(
        () => mockPlayer.setAudioSource(
          any(),
          initialIndex: 0,
          initialPosition: Duration.zero,
        ),
      ).called(1);
      expect(handler.currentQueue, [tTrack]);
    });

    test('play/pause/seek calls player methods', () async {
      when(() => mockPlayer.play()).thenAnswer((_) async => {});
      when(() => mockPlayer.pause()).thenAnswer((_) async => {});
      when(() => mockPlayer.seek(any())).thenAnswer((_) async => {});

      await handler.play();
      verify(() => mockPlayer.play()).called(1);

      await handler.pause();
      verify(() => mockPlayer.pause()).called(1);

      await handler.seek(const Duration(seconds: 10));
      verify(() => mockPlayer.seek(const Duration(seconds: 10))).called(1);
    });

    test('playbackEventStream updates playbackState', () async {
      final event = PlaybackEvent(
        processingState: ProcessingState.ready,
        currentIndex: 0,
      );
      when(() => mockPlayer.playing).thenReturn(true);
      when(() => mockPlayer.processingState).thenReturn(ProcessingState.ready);

      playbackEventController.add(event);

      await expectLater(
        handler.playbackState,
        emitsThrough(
          predicate<PlaybackState>(
            (state) =>
                state.playing == true &&
                state.processingState == AudioProcessingState.ready,
          ),
        ),
      );
    });

    test('currentIndexStream updates mediaItem', () async {
      await handler.loadQueue([tTrack], useCache: false);

      currentIndexController.add(0);

      await expectLater(
        handler.mediaItem,
        emitsThrough(
          predicate<MediaItem?>(
            (item) =>
                item != null &&
                item.id == tTrack.id &&
                item.title == tTrack.title,
          ),
        ),
      );
    });

    test('updateTrackInfo updates queue and mediaItem if current', () async {
      await handler.loadQueue([tTrack], useCache: false);
      final updatedTrack = tTrack.copyWith(title: 'Updated');

      when(() => mockPlayer.currentIndex).thenReturn(0);

      await handler.updateTrackInfo(tTrack.id, updatedTrack);

      expect(handler.currentQueue[0].title, 'Updated');

      await expectLater(
        handler.mediaItem,
        emitsThrough(
          predicate<MediaItem?>(
            (item) => item != null && item.title == 'Updated',
          ),
        ),
      );
    });

    test('skipToIndex calls player.seek', () async {
      await handler.loadQueue([tTrack, tTrack], useCache: false);

      when(
        () => mockPlayer.seek(any(), index: any(named: 'index')),
      ).thenAnswer((_) async => {});
      when(() => mockPlayer.play()).thenAnswer((_) async => {});

      await handler.skipToIndex(1);

      verify(() => mockPlayer.seek(Duration.zero, index: 1)).called(1);
      verify(() => mockPlayer.play()).called(1);
    });
  });
}
