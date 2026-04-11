import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/domain/usecases/get_player_state_stream_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/load_queue_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/play_pause_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/seek_position_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/skip_track_usecase.dart';
import 'package:rythmify/features/player/domain/usecases/update_track_info_usecase.dart';
import 'package:rythmify/features/player/presentation/providers/player_dependency_providers.dart';
import 'package:rythmify/features/player/presentation/providers/player_provider.dart';
import 'package:rythmify/features/track/domain/usecases/get_track_details.dart';
import 'package:rythmify/features/track/domain/usecases/get_waveform.dart';
import 'package:rythmify/features/track/presentation/providers/track_dependency_providers.dart';

class MockGetPlayerStateStreamUseCase extends Mock implements GetPlayerStateStreamUseCase {}
class MockLoadQueueUseCase extends Mock implements LoadQueueUseCase {}
class MockPlayTrackUseCase extends Mock implements PlayTrackUseCase {}
class MockPauseTrackUseCase extends Mock implements PauseTrackUseCase {}
class MockSkipToNextUseCase extends Mock implements SkipToNextUseCase {}
class MockSkipToPreviousUseCase extends Mock implements SkipToPreviousUseCase {}
class MockSeekPositionUseCase extends Mock implements SeekPositionUseCase {}
class MockUpdateTrackInfoUseCase extends Mock implements UpdateTrackInfoUseCase {}
class MockGetTrackDetailsUseCase extends Mock implements GetTrackDetails {}
class MockGetWaveformUseCase extends Mock implements GetWaveform {}

void main() {
  late ProviderContainer container;
  late MockGetPlayerStateStreamUseCase mockGetPlayerStateStream;
  late MockLoadQueueUseCase mockLoadQueue;
  late MockPlayTrackUseCase mockPlayTrack;
  late MockPauseTrackUseCase mockPauseTrack;
  late MockSkipToNextUseCase mockSkipNext;
  late MockSkipToPreviousUseCase mockSkipPrev;
  late MockSeekPositionUseCase mockSeekPosition;
  late MockUpdateTrackInfoUseCase mockUpdateTrackInfo;
  late MockGetTrackDetailsUseCase mockGetTrackDetails;
  late MockGetWaveformUseCase mockGetWaveform;

  late StreamController<AppPlayerState> streamController;

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
    mockGetPlayerStateStream = MockGetPlayerStateStreamUseCase();
    mockLoadQueue = MockLoadQueueUseCase();
    mockPlayTrack = MockPlayTrackUseCase();
    mockPauseTrack = MockPauseTrackUseCase();
    mockSkipNext = MockSkipToNextUseCase();
    mockSkipPrev = MockSkipToPreviousUseCase();
    mockSeekPosition = MockSeekPositionUseCase();
    mockUpdateTrackInfo = MockUpdateTrackInfoUseCase();
    mockGetTrackDetails = MockGetTrackDetailsUseCase();
    mockGetWaveform = MockGetWaveformUseCase();

    streamController = StreamController<AppPlayerState>.broadcast();
    when(() => mockGetPlayerStateStream.call()).thenAnswer((_) => streamController.stream);

    container = ProviderContainer(
      overrides: [
        getPlayerStateStreamUseCaseProvider.overrideWithValue(mockGetPlayerStateStream),
        loadQueueUseCaseProvider.overrideWithValue(mockLoadQueue),
        playTrackUseCaseProvider.overrideWithValue(mockPlayTrack),
        pauseTrackUseCaseProvider.overrideWithValue(mockPauseTrack),
        skipNextUseCaseProvider.overrideWithValue(mockSkipNext),
        skipPrevUseCaseProvider.overrideWithValue(mockSkipPrev),
        seekPositionUseCaseProvider.overrideWithValue(mockSeekPosition),
        updateTrackInfoUseCaseProvider.overrideWithValue(mockUpdateTrackInfo),
        getTrackDetailsUseCaseProvider.overrideWithValue(mockGetTrackDetails),
        getWaveformUseCaseProvider.overrideWithValue(mockGetWaveform),
      ],
    );
  });

  tearDown(() {
    streamController.close();
    container.dispose();
  });

  group('SeekDragNotifier', () {
    test('initial state is null', () {
      final state = container.read(seekDragPositionProvider);
      expect(state, isNull);
    });

    test('setPosition updates state', () {
      final notifier = container.read(seekDragPositionProvider.notifier);
      
      notifier.setPosition(const Duration(seconds: 10));
      expect(container.read(seekDragPositionProvider), const Duration(seconds: 10));

      notifier.setPosition(null);
      expect(container.read(seekDragPositionProvider), isNull);
    });
  });

  group('PlayerNotifier', () {
    test('initial state uses stream to update itself', () async {
      final sub = container.listen(playerStateProvider, (prev, next) {});
      
      streamController.add(const AppPlayerState(status: PlayerStatus.playing));
      await Future.delayed(Duration.zero);

      final state = container.read(playerStateProvider);
      expect(state.status, PlayerStatus.playing);

      sub.close();
    });

    test('ignores stream updates when dragging', () async {
      final sub = container.listen(playerStateProvider, (prev, next) {});
      final notifier = container.read(playerStateProvider.notifier);

      notifier.setDragging(true);
      
      streamController.add(const AppPlayerState(status: PlayerStatus.playing));
      await Future.delayed(Duration.zero);

      final state = container.read(playerStateProvider);
      expect(state.status, PlayerStatus.initial); // Unchanged

      sub.close();
    });

    test('loadAndPlayQueue calls correct use cases', () async {
      when(() => mockLoadQueue.call(any(), initialIndex: any(named: 'initialIndex')))
          .thenAnswer((_) async {});
      when(() => mockPlayTrack.call()).thenAnswer((_) async {});

      final notifier = container.read(playerStateProvider.notifier);
      await notifier.loadAndPlayQueue([tTrack], initialIndex: 1);

      verify(() => mockLoadQueue.call([tTrack], initialIndex: 1)).called(1);
      verify(() => mockPlayTrack.call()).called(1);
    });

    test('playOptimistic loads queue and updates track in background', () async {
      when(() => mockLoadQueue.call(any(), initialIndex: any(named: 'initialIndex')))
          .thenAnswer((_) async {});
      when(() => mockPlayTrack.call()).thenAnswer((_) async {});
      
      when(() => mockGetTrackDetails.call(any())).thenAnswer((_) async => tTrack);
      when(() => mockGetWaveform.call(any())).thenAnswer((_) async => [0.1, 0.2]);
      when(() => mockUpdateTrackInfo.call(any(), any())).thenAnswer((_) async {});

      final notifier = container.read(playerStateProvider.notifier);
      await notifier.playOptimistic(tTrack);

      verify(() => mockLoadQueue.call([tTrack], initialIndex: 0)).called(1);
      verify(() => mockPlayTrack.call()).called(1);

      // The background task needs time to run
      await Future.delayed(Duration.zero);

      verify(() => mockGetTrackDetails.call('track-1')).called(1);
      verify(() => mockGetWaveform.call('track-1')).called(1);
      
      final updatedTrack = tTrack.copyWith(waveformData: [0.1, 0.2]);
      verify(() => mockUpdateTrackInfo.call('track-1', updatedTrack)).called(1);
    });

    test('togglePlayPause calls pause if playing', () {
      final notifier = container.read(playerStateProvider.notifier);
      
      // Simulate stream update to change state to playing
      streamController.add(const AppPlayerState(status: PlayerStatus.playing));
      
      notifier.togglePlayPause();
      
      verify(() => mockPauseTrack.call()).called(1);
    });

    test('skipToNext calls skipNextUseCase', () {
      when(() => mockSkipNext.call()).thenAnswer((_) async {});
      
      final notifier = container.read(playerStateProvider.notifier);
      notifier.skipToNext();

      verify(() => mockSkipNext.call()).called(1);
    });

    test('skipToPrevious calls skipPrevUseCase', () {
      when(() => mockSkipPrev.call()).thenAnswer((_) async {});
      
      final notifier = container.read(playerStateProvider.notifier);
      notifier.skipToPrevious();

      verify(() => mockSkipPrev.call()).called(1);
    });

    test('seek calls seekPositionUseCase', () {
      when(() => mockSeekPosition.call(any())).thenAnswer((_) async {});
      
      final notifier = container.read(playerStateProvider.notifier);
      notifier.seek(const Duration(seconds: 10));

      verify(() => mockSeekPosition.call(const Duration(seconds: 10))).called(1);
    });

    test('updatePosition updates local state position', () {
      final notifier = container.read(playerStateProvider.notifier);
      notifier.updatePosition(const Duration(seconds: 15));
      
      expect(container.read(playerStateProvider).position, const Duration(seconds: 15));
    });

    test('stopPlayback pauses and seeks to zero', () async {
      when(() => mockPauseTrack.call()).thenAnswer((_) async {});
      when(() => mockSeekPosition.call(any())).thenAnswer((_) async {});
      
      final notifier = container.read(playerStateProvider.notifier);
      await notifier.stopPlayback();

      verify(() => mockPauseTrack.call()).called(1);
      verify(() => mockSeekPosition.call(Duration.zero)).called(1);
    });
  });
}
