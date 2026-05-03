import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/presentation/providers/player_provider.dart';
import 'package:rythmify/features/player/presentation/providers/player_dependency_providers.dart';
import 'package:rythmify/features/track/presentation/providers/track_dependency_providers.dart';
import 'package:rythmify/features/player/presentation/providers/ad_provider.dart';
import '../presentation_test_helper.dart';

// Use a wrapper to safely mock Notifiers in Riverpod
class MockAdNotifier extends Mock implements AdNotifier {}

class MockAdNotifierWrapper extends AdNotifier {
  final AdState _state;
  final MockAdNotifier _mock;
  MockAdNotifierWrapper(this._state, this._mock);
  @override
  AdState build() => _state;
  @override
  Future<void> incrementTrackCount() => _mock.incrementTrackCount();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAudioRepository mockAudioRepository;
  late MockPlayTrackUseCase mockPlayTrackUseCase;
  late MockPauseTrackUseCase mockPauseTrackUseCase;
  late MockSkipToNextUseCase mockSkipNextUseCase;
  late MockSkipToPreviousUseCase mockSkipPrevUseCase;
  late MockSeekPositionUseCase mockSeekPositionUseCase;
  late MockGetPlayerStateStreamUseCase mockGetPlayerStateStreamUseCase;
  late MockLoadQueueUseCase mockLoadQueueUseCase;
  late MockUpdateTrackInfoUseCase mockUpdateTrackInfoUseCase;
  late MockInitiatePlaybackUseCase mockInitiatePlaybackUseCase;
  late MockRecordListeningHistoryUseCase mockRecordListeningHistoryUseCase;
  late MockSyncHistoryUseCase mockSyncHistoryUseCase;
  late MockGetTrackDetails mockGetTrackDetails;
  late MockGetWaveform mockGetWaveform;
  late MockAdNotifier mockAdNotifier;

  late StreamController<AppPlayerState> playerStateController;

  setUpAll(() {
    registerPlayerFallbackValues();
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    mockAudioRepository = MockAudioRepository();
    mockPlayTrackUseCase = MockPlayTrackUseCase();
    mockPauseTrackUseCase = MockPauseTrackUseCase();
    mockSkipNextUseCase = MockSkipToNextUseCase();
    mockSkipPrevUseCase = MockSkipToPreviousUseCase();
    mockSeekPositionUseCase = MockSeekPositionUseCase();
    mockGetPlayerStateStreamUseCase = MockGetPlayerStateStreamUseCase();
    mockLoadQueueUseCase = MockLoadQueueUseCase();
    mockUpdateTrackInfoUseCase = MockUpdateTrackInfoUseCase();
    mockInitiatePlaybackUseCase = MockInitiatePlaybackUseCase();
    mockRecordListeningHistoryUseCase = MockRecordListeningHistoryUseCase();
    mockSyncHistoryUseCase = MockSyncHistoryUseCase();
    mockGetTrackDetails = MockGetTrackDetails();
    mockGetWaveform = MockGetWaveform();
    mockAdNotifier = MockAdNotifier();

    playerStateController = StreamController<AppPlayerState>.broadcast();

    when(
      () => mockGetPlayerStateStreamUseCase.call(),
    ).thenAnswer((_) => playerStateController.stream);
    when(() => mockSyncHistoryUseCase.call()).thenAnswer((_) async {});
    when(
      () => mockRecordListeningHistoryUseCase.call(any()),
    ).thenAnswer((_) async {});
    when(() => mockPlayTrackUseCase.call()).thenAnswer((_) async {});
    when(() => mockPauseTrackUseCase.call()).thenAnswer((_) async {});
    when(() => mockSkipNextUseCase.call()).thenAnswer((_) async {});
    when(() => mockSkipPrevUseCase.call()).thenAnswer((_) async {});
    when(() => mockSeekPositionUseCase.call(any())).thenAnswer((_) async {});
    when(
      () => mockLoadQueueUseCase.call(
        any(),
        initialIndex: any(named: 'initialIndex'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockInitiatePlaybackUseCase.call(any()),
    ).thenAnswer((_) async => 'url');
    when(
      () => mockUpdateTrackInfoUseCase.call(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockGetTrackDetails.call(any()),
    ).thenAnswer((_) async => testTrack);
    when(() => mockGetWaveform.call(any())).thenAnswer((_) async => [0.1, 0.5]);

    // Stub the mock instance
    when(() => mockAdNotifier.incrementTrackCount()).thenAnswer((_) async {});
  });

  tearDown(() {
    playerStateController.close();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        audioRepositoryProvider.overrideWithValue(mockAudioRepository),
        playTrackUseCaseProvider.overrideWithValue(mockPlayTrackUseCase),
        pauseTrackUseCaseProvider.overrideWithValue(mockPauseTrackUseCase),
        skipNextUseCaseProvider.overrideWithValue(mockSkipNextUseCase),
        skipPrevUseCaseProvider.overrideWithValue(mockSkipPrevUseCase),
        seekPositionUseCaseProvider.overrideWithValue(mockSeekPositionUseCase),
        getPlayerStateStreamUseCaseProvider.overrideWithValue(
          mockGetPlayerStateStreamUseCase,
        ),
        loadQueueUseCaseProvider.overrideWithValue(mockLoadQueueUseCase),
        updateTrackInfoUseCaseProvider.overrideWithValue(
          mockUpdateTrackInfoUseCase,
        ),
        initiatePlaybackUseCaseProvider.overrideWithValue(
          mockInitiatePlaybackUseCase,
        ),
        recordListeningHistoryUseCaseProvider.overrideWithValue(
          mockRecordListeningHistoryUseCase,
        ),
        syncHistoryUseCaseProvider.overrideWithValue(mockSyncHistoryUseCase),
        getTrackDetailsUseCaseProvider.overrideWithValue(mockGetTrackDetails),
        getWaveformUseCaseProvider.overrideWithValue(mockGetWaveform),
        adProvider.overrideWith(
          () => MockAdNotifierWrapper(
            const AdState(trackCount: 0, showAd: false),
            mockAdNotifier,
          ),
        ),
      ],
    );
    return container;
  }

  group('PlayerNotifier', () {
    test('initial state is AppPlayerState()', () {
      final container = createContainer();
      expect(container.read(playerStateProvider), const AppPlayerState());
    });

    test('syncs with domain stream', () async {
      final container = createContainer();
      container.listen(playerStateProvider, (_, __) {});

      final newState = AppPlayerState(
        currentTrack: testTrack,
        status: PlayerStatus.playing,
      );

      playerStateController.add(newState);
      await pumpEventQueue();

      expect(container.read(playerStateProvider), newState);
    });

    test('loadAndPlayQueue calls correct use cases', () async {
      final container = createContainer();
      final tracks = [testTrack];

      await container
          .read(playerStateProvider.notifier)
          .loadAndPlayQueue(tracks);

      verify(() => mockInitiatePlaybackUseCase.call(testTrack.id)).called(1);
      verify(() => mockLoadQueueUseCase.call(any(), initialIndex: 0)).called(1);
      verify(() => mockPlayTrackUseCase.call()).called(1);
    });

    test('addToQueueNext appends track when nothing playing', () async {
      final container = createContainer();
      await container
          .read(playerStateProvider.notifier)
          .addToQueueNext(testTrack);
      verify(() => mockLoadQueueUseCase.call(any(), initialIndex: 0)).called(1);
    });

    test('addToQueueNext inserts track after current when playing', () async {
      final container = createContainer();
      container.listen(playerStateProvider, (_, __) {});

      // Load initial track
      await container.read(playerStateProvider.notifier).loadAndPlayQueue([
        testTrack,
      ]);

      // Update state to reflect current track
      playerStateController.add(
        AppPlayerState(currentTrack: testTrack, status: PlayerStatus.playing),
      );
      await pumpEventQueue();

      final nextTrack = testTrack.copyWith(id: 'next');
      await container
          .read(playerStateProvider.notifier)
          .addToQueueNext(nextTrack);

      verify(() => mockInitiatePlaybackUseCase.call(nextTrack.id)).called(1);
      // loadQueueUseCase called once in loadAndPlayQueue and once in addToQueueNext
      verify(() => mockLoadQueueUseCase.call(any(), initialIndex: 0)).called(2);
    });

    test('addToQueueLast appends track when playing', () async {
      final container = createContainer();
      container.listen(playerStateProvider, (_, __) {});

      // Load initial track
      await container.read(playerStateProvider.notifier).loadAndPlayQueue([
        testTrack,
      ]);

      // Update state to reflect current track
      playerStateController.add(
        AppPlayerState(currentTrack: testTrack, status: PlayerStatus.playing),
      );
      await pumpEventQueue();

      final lastTrack = testTrack.copyWith(id: 'last');
      await container
          .read(playerStateProvider.notifier)
          .addToQueueLast(lastTrack);

      verify(() => mockInitiatePlaybackUseCase.call(lastTrack.id)).called(1);
      verify(() => mockLoadQueueUseCase.call(any(), initialIndex: 0)).called(2);
    });

    test('playOptimistic initiates and loads', () async {
      final container = createContainer();
      await container
          .read(playerStateProvider.notifier)
          .playOptimistic(testTrack);
      verify(
        () => mockInitiatePlaybackUseCase.call(testTrack.id),
      ).called(2); // once in playOptimistic, once in loadAndPlayQueue
      verify(() => mockLoadQueueUseCase.call(any(), initialIndex: 0)).called(1);
    });

    test('_updateTrackInBackground handles errors gracefully', () async {
      final container = createContainer();
      container.listen(playerStateProvider, (_, __) {});

      final failingTrack = testTrack.copyWith(id: 'failing_track');

      when(
        () => mockGetTrackDetails.call('failing_track'),
      ).thenThrow(Exception('Details fail'));
      when(
        () => mockGetWaveform.call('failing_track'),
      ).thenThrow(Exception('Waveform fail'));

      playerStateController.add(AppPlayerState(currentTrack: failingTrack));
      await pumpEventQueue();
      await Future.delayed(const Duration(milliseconds: 100));

      // Should not call updateTrackInfoUseCase if both fail
      verifyNever(
        () => mockUpdateTrackInfoUseCase.call('failing_track', any()),
      );
    });

    test('_recordCurrentSession records history when time has elapsed', () async {
      final container = createContainer();
      container.listen(playerStateProvider, (_, __) {});

      // 1. Start session
      playerStateController.add(
        AppPlayerState(currentTrack: testTrack, status: PlayerStatus.playing),
      );
      await pumpEventQueue();

      // 2. Wait for time to elapse (using real time here as it's easier than fakeAsync for Notifier)
      await Future.delayed(const Duration(seconds: 1));

      // 3. Change track to trigger recording
      playerStateController.add(
        AppPlayerState(
          currentTrack: testTrack.copyWith(id: 'new_track'),
          status: PlayerStatus.playing,
        ),
      );
      await pumpEventQueue();

      verify(() => mockRecordListeningHistoryUseCase.call(any())).called(1);
    });

    test('_updateTrackInBackground updates metadata if changed', () async {
      final container = createContainer();
      container.listen(playerStateProvider, (_, __) {});

      playerStateController.add(AppPlayerState(currentTrack: testTrack));
      await pumpEventQueue();

      final updatedTrack = testTrack.copyWith(artistUsername: 'new_user');
      when(
        () => mockGetTrackDetails.call(any()),
      ).thenAnswer((_) async => updatedTrack);

      // Trigger by a stream event with same track but no waveform to trigger _updateTrackInBackground
      playerStateController.add(AppPlayerState(currentTrack: testTrack));
      await pumpEventQueue();
      await Future.delayed(const Duration(milliseconds: 100));

      verify(
        () => mockUpdateTrackInfoUseCase.call(testTrack.id, any()),
      ).called(1);
    });

    test('skipToAbsoluteIndex resolves URL JIT if missing', () async {
      final container = createContainer();
      final trackNoUrl = testTrack.copyWith(audioUrl: '', streamUrl: '');

      when(() => mockAudioRepository.currentQueue).thenReturn([trackNoUrl]);
      when(() => mockAudioRepository.skipToIndex(0)).thenAnswer((_) async {});
      when(
        () => mockAudioRepository.updateTrackInfo(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockInitiatePlaybackUseCase.call(trackNoUrl.id),
      ).thenAnswer((_) async => 'resolved-url');

      // Populate internal _queue
      await container.read(playerStateProvider.notifier).loadAndPlayQueue([
        trackNoUrl,
      ]);

      await container.read(playerStateProvider.notifier).skipToAbsoluteIndex(0);

      verify(
        () => mockInitiatePlaybackUseCase.call(trackNoUrl.id),
      ).called(2); // once in loadAndPlayQueue, once in skipToAbsoluteIndex
      verify(
        () => mockAudioRepository.updateTrackInfo(trackNoUrl.id, any()),
      ).called(1);
      verify(() => mockAudioRepository.skipToIndex(0)).called(1);
    });

    test('updateNativeQueue with newIndex calls loadQueue', () async {
      final container = createContainer();
      final tracks = [testTrack];
      when(
        () => mockAudioRepository.loadQueue(
          any(),
          initialIndex: any(named: 'initialIndex'),
        ),
      ).thenAnswer((_) async {});

      await container
          .read(playerStateProvider.notifier)
          .updateNativeQueue(tracks, newIndex: 0);

      verify(
        () => mockAudioRepository.loadQueue(tracks, initialIndex: 0),
      ).called(1);
    });

    test('updateNativeQueue without newIndex calls updateQueue', () async {
      final container = createContainer();
      final tracks = [testTrack];
      when(
        () => mockAudioRepository.updateQueue(any()),
      ).thenAnswer((_) async {});

      await container
          .read(playerStateProvider.notifier)
          .updateNativeQueue(tracks);

      verify(() => mockAudioRepository.updateQueue(tracks)).called(1);
    });

    test('moveTrack removes and inserts and calls repository', () async {
      final container = createContainer();
      when(
        () => mockAudioRepository.moveTrack(any(), any()),
      ).thenAnswer((_) async {});

      // Populate internal _queue
      await container.read(playerStateProvider.notifier).loadAndPlayQueue([
        testTrack,
        testTrack.copyWith(id: 't2'),
      ]);

      await container.read(playerStateProvider.notifier).moveTrack(0, 1);
      verify(() => mockAudioRepository.moveTrack(0, 1)).called(1);
    });

    test('updatePosition updates state and sets local seek time', () {
      final container = createContainer();
      const position = Duration(seconds: 30);
      container.read(playerStateProvider.notifier).updatePosition(position);
      expect(container.read(playerStateProvider).position, position);
    });

    test('setDragging updates internal flag', () {
      final container = createContainer();
      container.read(playerStateProvider.notifier).setDragging(true);
    });

    test('stopPlayback records history and pauses', () async {
      final container = createContainer();
      container.listen(playerStateProvider, (_, __) {});

      playerStateController.add(
        AppPlayerState(currentTrack: testTrack, status: PlayerStatus.playing),
      );
      await pumpEventQueue();

      await container.read(playerStateProvider.notifier).stopPlayback();

      verify(() => mockPauseTrackUseCase.call()).called(1);
      verify(() => mockSeekPositionUseCase.call(Duration.zero)).called(1);
    });

    test('loadAndPlayPreview calls loadQueue', () async {
      final container = createContainer();
      await container
          .read(playerStateProvider.notifier)
          .loadAndPlayPreview(testTrack);
      verify(
        () => mockLoadQueueUseCase.call([testTrack], initialIndex: 0),
      ).called(1);
    });

    test('SeekDragNotifier sets position', () {
      final container = createContainer();
      container
          .read(seekDragPositionProvider.notifier)
          .setPosition(const Duration(seconds: 10));
      expect(
        container.read(seekDragPositionProvider),
        const Duration(seconds: 10),
      );
    });
  });
}
