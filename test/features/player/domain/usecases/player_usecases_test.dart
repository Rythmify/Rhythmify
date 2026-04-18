import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/domain/repositories/audio_repository.dart';
import 'package:rythmify/features/player/domain/usecases/get_player_state_stream_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/load_queue_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/play_pause_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/seek_position_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/skip_track_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/update_track_info_usecase.dart';

class MockAudioRepository extends Mock implements AudioRepository {}

void main() {
  late MockAudioRepository mockRepository;

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
    mockRepository = MockAudioRepository();
  });

  group('GetPlayerStateStreamUseCase', () {
    late GetPlayerStateStreamUseCase usecase;

    setUp(() {
      usecase = GetPlayerStateStreamUseCase(mockRepository);
    });

    test('should return stream from repository', () {
      final tStream = Stream.value(const AppPlayerState());
      when(() => mockRepository.playerStateStream).thenAnswer((_) => tStream);

      final result = usecase();

      expect(result, tStream);
      verify(() => mockRepository.playerStateStream).called(1);
    });
  });

  group('LoadQueueUseCase', () {
    late LoadQueueUseCase usecase;

    setUp(() {
      usecase = LoadQueueUseCase(mockRepository);
    });

    test('should call loadQueue on repository', () async {
      when(
        () => mockRepository.loadQueue(
          any(),
          initialIndex: any(named: 'initialIndex'),
        ),
      ).thenAnswer((_) async {});

      await usecase([tTrack], initialIndex: 1);

      verify(
        () => mockRepository.loadQueue([tTrack], initialIndex: 1),
      ).called(1);
    });
  });

  group('PlayTrackUseCase', () {
    late PlayTrackUseCase usecase;

    setUp(() {
      usecase = PlayTrackUseCase(mockRepository);
    });

    test('should call play on repository', () async {
      when(() => mockRepository.play()).thenAnswer((_) async {});

      await usecase();

      verify(() => mockRepository.play()).called(1);
    });
  });

  group('PauseTrackUseCase', () {
    late PauseTrackUseCase usecase;

    setUp(() {
      usecase = PauseTrackUseCase(mockRepository);
    });

    test('should call pause on repository', () async {
      when(() => mockRepository.pause()).thenAnswer((_) async {});

      await usecase();

      verify(() => mockRepository.pause()).called(1);
    });
  });

  group('SeekPositionUseCase', () {
    late SeekPositionUseCase usecase;

    setUp(() {
      usecase = SeekPositionUseCase(mockRepository);
    });

    test('should call seek on repository', () async {
      when(() => mockRepository.seek(any())).thenAnswer((_) async {});

      await usecase(const Duration(seconds: 10));

      verify(() => mockRepository.seek(const Duration(seconds: 10))).called(1);
    });
  });

  group('SkipToNextUseCase', () {
    late SkipToNextUseCase usecase;

    setUp(() {
      usecase = SkipToNextUseCase(mockRepository);
    });

    test('should call skipToNext on repository', () async {
      when(() => mockRepository.skipToNext()).thenAnswer((_) async {});

      await usecase();

      verify(() => mockRepository.skipToNext()).called(1);
    });
  });

  group('SkipToPreviousUseCase', () {
    late SkipToPreviousUseCase usecase;

    setUp(() {
      usecase = SkipToPreviousUseCase(mockRepository);
    });

    test('should call skipToPrevious on repository', () async {
      when(() => mockRepository.skipToPrevious()).thenAnswer((_) async {});

      await usecase();

      verify(() => mockRepository.skipToPrevious()).called(1);
    });
  });

  group('UpdateTrackInfoUseCase', () {
    late UpdateTrackInfoUseCase usecase;

    setUp(() {
      usecase = UpdateTrackInfoUseCase(mockRepository);
    });

    test('should call updateTrackInfo on repository', () async {
      when(
        () => mockRepository.updateTrackInfo(any(), any()),
      ).thenAnswer((_) async {});

      await usecase('track-1', tTrack);

      verify(() => mockRepository.updateTrackInfo('track-1', tTrack)).called(1);
    });
  });
}
