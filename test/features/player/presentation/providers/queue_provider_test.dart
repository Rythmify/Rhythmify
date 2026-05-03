import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/player/domain/entities/player_state.dart';
import 'package:rythmify/features/player/domain/entities/queue_state.dart';
import 'package:rythmify/features/player/domain/entities/queue_item.dart';
import 'package:rythmify/features/player/presentation/providers/queue_provider.dart';
import 'package:rythmify/features/player/presentation/providers/player_provider.dart';
import 'package:rythmify/features/player/presentation/providers/player_dependency_providers.dart';
import 'package:rythmify/features/track/presentation/providers/track_dependency_providers.dart';
import 'package:rythmify/features/player/presentation/providers/ad_provider.dart';
import '../presentation_test_helper.dart';

class MockAdNotifier extends Notifier<AdState>
    with Mock
    implements AdNotifier {}

class MockPlayerNotifier extends Notifier<AppPlayerState>
    with Mock
    implements PlayerNotifier {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAudioRepository mockAudioRepository;
  late MockPlayTrackUseCase mockPlayTrackUseCase;
  late MockGetPlayerStateStreamUseCase mockGetPlayerStateStreamUseCase;
  late MockLoadQueueUseCase mockLoadQueueUseCase;
  late MockSyncPlayerStateUseCase mockSyncPlayerStateUseCase;
  late MockGetRelatedTracksUseCase mockGetRelatedTracksUseCase;
  late MockAppendTracksUseCase mockAppendTracksUseCase;
  late MockSyncHistoryUseCase mockSyncHistoryUseCase;
  late MockInitiatePlaybackUseCase mockInitiatePlaybackUseCase;
  late MockRecordListeningHistoryUseCase mockRecordListeningHistoryUseCase;
  late MockFetchQueueContextUseCase mockFetchQueueContextUseCase;
  late MockUpdateTrackInfoUseCase mockUpdateTrackInfoUseCase;
  late MockGetTrackDetails mockGetTrackDetails;
  late MockGetWaveform mockGetWaveform;
  late MockAdNotifier mockAdNotifier;
  late MockPlayerNotifier mockPlayerNotifier;

  late StreamController<AppPlayerState> playerStateController;

  setUpAll(() {
    registerPlayerFallbackValues();
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() {
    mockAudioRepository = MockAudioRepository();
    mockPlayTrackUseCase = MockPlayTrackUseCase();
    mockGetPlayerStateStreamUseCase = MockGetPlayerStateStreamUseCase();
    mockLoadQueueUseCase = MockLoadQueueUseCase();
    mockSyncPlayerStateUseCase = MockSyncPlayerStateUseCase();
    mockGetRelatedTracksUseCase = MockGetRelatedTracksUseCase();
    mockAppendTracksUseCase = MockAppendTracksUseCase();
    mockSyncHistoryUseCase = MockSyncHistoryUseCase();
    mockInitiatePlaybackUseCase = MockInitiatePlaybackUseCase();
    mockRecordListeningHistoryUseCase = MockRecordListeningHistoryUseCase();
    mockFetchQueueContextUseCase = MockFetchQueueContextUseCase();
    mockUpdateTrackInfoUseCase = MockUpdateTrackInfoUseCase();
    mockGetTrackDetails = MockGetTrackDetails();
    mockGetWaveform = MockGetWaveform();
    mockAdNotifier = MockAdNotifier();
    mockPlayerNotifier = MockPlayerNotifier();

    playerStateController = StreamController<AppPlayerState>.broadcast();

    when(
      () => mockGetPlayerStateStreamUseCase.call(),
    ).thenAnswer((_) => playerStateController.stream);
    when(() => mockSyncHistoryUseCase.call()).thenAnswer((_) async {});
    when(
      () => mockRecordListeningHistoryUseCase.call(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockSyncPlayerStateUseCase.call(
        trackId: any(named: 'trackId'),
        queue: any(named: 'queue'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockLoadQueueUseCase.call(
        any(),
        initialIndex: any(named: 'initialIndex'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockInitiatePlaybackUseCase.call(any()),
    ).thenAnswer((_) async => 'url');
    when(() => mockPlayTrackUseCase.call()).thenAnswer((_) async {});
    when(
      () => mockGetRelatedTracksUseCase.call(any()),
    ).thenAnswer((_) async => <Track>[]);
    when(() => mockAppendTracksUseCase.call(any())).thenAnswer((_) async {});
    when(
      () => mockUpdateTrackInfoUseCase.call(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockGetTrackDetails.call(any()),
    ).thenAnswer((_) async => testTrack);
    when(() => mockGetWaveform.call(any())).thenAnswer((_) async => [0.1, 0.5]);

    // Fix: Stub incrementTrackCount
    when(() => mockAdNotifier.incrementTrackCount()).thenAnswer((_) async {});

    // Default stubs for notifiers
    when(
      () => mockAdNotifier.build(),
    ).thenReturn(const AdState(trackCount: 0, showAd: false));
    when(() => mockPlayerNotifier.build()).thenReturn(const AppPlayerState());

    // Explicit stubs for PlayerNotifier methods used in QueueNotifier
    when(
      () => mockPlayerNotifier.updateNativeQueue(
        any(),
        newIndex: any(named: 'newIndex'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockPlayerNotifier.updateNativeQueue(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockPlayerNotifier.loadAndPlayQueue(
        any(),
        initialIndex: any(named: 'initialIndex'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockPlayerNotifier.skipToAbsoluteIndex(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockPlayerNotifier.moveTrack(any(), any()),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    playerStateController.close();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        audioRepositoryProvider.overrideWithValue(mockAudioRepository),
        playTrackUseCaseProvider.overrideWithValue(mockPlayTrackUseCase),
        getPlayerStateStreamUseCaseProvider.overrideWithValue(
          mockGetPlayerStateStreamUseCase,
        ),
        loadQueueUseCaseProvider.overrideWithValue(mockLoadQueueUseCase),
        syncPlayerStateUseCaseProvider.overrideWithValue(
          mockSyncPlayerStateUseCase,
        ),
        getRelatedTracksUseCaseProvider.overrideWithValue(
          mockGetRelatedTracksUseCase,
        ),
        appendTracksUseCaseProvider.overrideWithValue(mockAppendTracksUseCase),
        syncHistoryUseCaseProvider.overrideWithValue(mockSyncHistoryUseCase),
        initiatePlaybackUseCaseProvider.overrideWithValue(
          mockInitiatePlaybackUseCase,
        ),
        recordListeningHistoryUseCaseProvider.overrideWithValue(
          mockRecordListeningHistoryUseCase,
        ),
        fetchQueueContextUseCaseProvider.overrideWithValue(
          mockFetchQueueContextUseCase,
        ),
        updateTrackInfoUseCaseProvider.overrideWithValue(
          mockUpdateTrackInfoUseCase,
        ),
        getTrackDetailsUseCaseProvider.overrideWithValue(mockGetTrackDetails),
        getWaveformUseCaseProvider.overrideWithValue(mockGetWaveform),
        adProvider.overrideWith(() => mockAdNotifier),
        playerStateProvider.overrideWith(() => mockPlayerNotifier),
      ],
    );
  }

  group('QueueNotifier', () {
    test('initial state is AppQueueState()', () {
      final container = createContainer();
      expect(container.read(queueStateProvider), const AppQueueState());
    });

    test('syncs with hardware when playerState changes track', () async {
      final container = ProviderContainer(
        overrides: [
          audioRepositoryProvider.overrideWithValue(mockAudioRepository),
          playTrackUseCaseProvider.overrideWithValue(mockPlayTrackUseCase),
          getPlayerStateStreamUseCaseProvider.overrideWithValue(
            mockGetPlayerStateStreamUseCase,
          ),
          loadQueueUseCaseProvider.overrideWithValue(mockLoadQueueUseCase),
          syncPlayerStateUseCaseProvider.overrideWithValue(
            mockSyncPlayerStateUseCase,
          ),
          getRelatedTracksUseCaseProvider.overrideWithValue(
            mockGetRelatedTracksUseCase,
          ),
          appendTracksUseCaseProvider.overrideWithValue(
            mockAppendTracksUseCase,
          ),
          syncHistoryUseCaseProvider.overrideWithValue(mockSyncHistoryUseCase),
          initiatePlaybackUseCaseProvider.overrideWithValue(
            mockInitiatePlaybackUseCase,
          ),
          recordListeningHistoryUseCaseProvider.overrideWithValue(
            mockRecordListeningHistoryUseCase,
          ),
          fetchQueueContextUseCaseProvider.overrideWithValue(
            mockFetchQueueContextUseCase,
          ),
          updateTrackInfoUseCaseProvider.overrideWithValue(
            mockUpdateTrackInfoUseCase,
          ),
          getTrackDetailsUseCaseProvider.overrideWithValue(mockGetTrackDetails),
          getWaveformUseCaseProvider.overrideWithValue(mockGetWaveform),
          adProvider.overrideWith(() => mockAdNotifier),
        ],
      );

      final List<Track> tracks = [testTrack, testTrack.copyWith(id: 'track2')];

      container.listen(playerStateProvider, (_, __) {});

      await container
          .read(queueStateProvider.notifier)
          .playQueue(tracks: tracks, initialIndex: 0);

      expect(
        container.read(queueStateProvider).currentTrack?.track.id,
        testTrack.id,
      );

      playerStateController.add(
        AppPlayerState(currentTrack: tracks[1], queueIndex: 1),
      );

      await pumpEventQueue();

      expect(
        container.read(queueStateProvider).currentTrack?.track.id,
        'track2',
      );
      expect(container.read(queueStateProvider).history.length, 1);
    });

    test('_checkAndFetchRelated fetches and filters duplicates', () async {
      // Let's use a real PlayerNotifier for this test to be sure
      final containerWithRealPlayer = ProviderContainer(
        overrides: [
          audioRepositoryProvider.overrideWithValue(mockAudioRepository),
          playTrackUseCaseProvider.overrideWithValue(mockPlayTrackUseCase),
          getPlayerStateStreamUseCaseProvider.overrideWithValue(
            mockGetPlayerStateStreamUseCase,
          ),
          loadQueueUseCaseProvider.overrideWithValue(mockLoadQueueUseCase),
          syncPlayerStateUseCaseProvider.overrideWithValue(
            mockSyncPlayerStateUseCase,
          ),
          getRelatedTracksUseCaseProvider.overrideWithValue(
            mockGetRelatedTracksUseCase,
          ),
          appendTracksUseCaseProvider.overrideWithValue(
            mockAppendTracksUseCase,
          ),
          syncHistoryUseCaseProvider.overrideWithValue(mockSyncHistoryUseCase),
          initiatePlaybackUseCaseProvider.overrideWithValue(
            mockInitiatePlaybackUseCase,
          ),
          recordListeningHistoryUseCaseProvider.overrideWithValue(
            mockRecordListeningHistoryUseCase,
          ),
          fetchQueueContextUseCaseProvider.overrideWithValue(
            mockFetchQueueContextUseCase,
          ),
          updateTrackInfoUseCaseProvider.overrideWithValue(
            mockUpdateTrackInfoUseCase,
          ),
          getTrackDetailsUseCaseProvider.overrideWithValue(mockGetTrackDetails),
          getWaveformUseCaseProvider.overrideWithValue(mockGetWaveform),
          adProvider.overrideWith(() => mockAdNotifier),
        ],
      );

      final relatedTrack = testTrack.copyWith(id: 'related1');

      when(
        () => mockGetRelatedTracksUseCase.call(any()),
      ).thenAnswer((_) async => [testTrack, relatedTrack]);
      when(
        () => mockGetTrackDetails.call(any()),
      ).thenAnswer((_) async => relatedTrack);
      when(
        () => mockGetWaveform.call(any()),
      ).thenAnswer((_) async => [0.1, 0.2]);

      containerWithRealPlayer.listen(playerStateProvider, (_, __) {});

      await containerWithRealPlayer
          .read(queueStateProvider.notifier)
          .playQueue(tracks: [testTrack], initialIndex: 0);

      // Trigger track change which calls _checkAndFetchRelated
      playerStateController.add(
        AppPlayerState(currentTrack: testTrack, queueIndex: 0),
      );

      await pumpEventQueue();
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // wait for background resolution
      await pumpEventQueue();

      final state = containerWithRealPlayer.read(queueStateProvider);
      expect(state.upcomingTracks.any((t) => t.track.id == 'related1'), true);
      expect(
        state.upcomingTracks.where((t) => t.track.id == testTrack.id).length,
        0,
      );
    });

    test('addToNextUp fetches and inserts tracks', () async {
      final container = createContainer();
      final nextUpTrack = testTrack.copyWith(id: 'nextUp');

      when(
        () => mockFetchQueueContextUseCase.call(
          interactionType: 'next_up',
          sourceType: any(named: 'sourceType'),
          sourceId: any(named: 'sourceId'),
        ),
      ).thenAnswer(
        (_) async => {
          'data': {
            'queue': [
              {
                'id': nextUpTrack.id,
                'user_id': nextUpTrack.userId,
                'title': nextUpTrack.title,
                'artist': nextUpTrack.artist,
                'audio_url': nextUpTrack.audioUrl,
                'duration_ms': nextUpTrack.duration.inMilliseconds,
                'created_at': nextUpTrack.createdAt.toIso8601String(),
                'queue_item_id': 'next1',
              },
            ],
          },
        },
      );

      await container
          .read(queueStateProvider.notifier)
          .playQueue(tracks: [testTrack], initialIndex: 0);

      await container
          .read(queueStateProvider.notifier)
          .addToNextUp(sourceType: 'album');

      final state = container.read(queueStateProvider);
      expect(state.upcomingTracks.any((t) => t.track.id == 'nextUp'), true);
    });

    test('addMultipleToQueueNext inserts tracks after current', () async {
      final container = createContainer();
      final tracks = [
        testTrack.copyWith(id: 'next1'),
        testTrack.copyWith(id: 'next2'),
      ];

      await container
          .read(queueStateProvider.notifier)
          .playQueue(tracks: [testTrack], initialIndex: 0);

      await container
          .read(queueStateProvider.notifier)
          .addMultipleToQueueNext(tracks);

      final state = container.read(queueStateProvider);
      expect(state.upcomingTracks.length, 2);
      expect(state.upcomingTracks[0].track.id, 'next1');
      expect(state.upcomingTracks[1].track.id, 'next2');
    });

    test(
      'addMultipleToQueueLast appends tracks before recommendations',
      () async {
        final container = createContainer();
        final tracks = [
          testTrack.copyWith(id: 'last1'),
          testTrack.copyWith(id: 'last2'),
        ];

        await container
            .read(queueStateProvider.notifier)
            .playQueue(tracks: [testTrack], initialIndex: 0);

        // Add a recommended track
        final recItem = QueueItem(
          track: testTrack.copyWith(id: 'rec1'),
          isRecommended: true,
        );
        container.read(queueStateProvider.notifier).state = container
            .read(queueStateProvider)
            .copyWith(upcomingTracks: [recItem]);

        await container
            .read(queueStateProvider.notifier)
            .addMultipleToQueueLast(tracks);

        final state = container.read(queueStateProvider);
        expect(state.upcomingTracks.length, 3);
        expect(state.upcomingTracks[0].track.id, 'last1');
        expect(state.upcomingTracks[1].track.id, 'last2');
        expect(state.upcomingTracks[2].isRecommended, true);
      },
    );

    test('playFromQueue skips to correct absolute index', () async {
      final container = createContainer();

      await container
          .read(queueStateProvider.notifier)
          .playQueue(
            tracks: [
              testTrack,
              testTrack.copyWith(id: 't2'),
              testTrack.copyWith(id: 't3'),
            ],
            initialIndex: 0,
          );

      // Current state: history=[], current=testTrack, upcoming=[t2, t3]
      // playFromQueue(0) should play t2. Absolute index = 0 (history) + 1 (current) + 0 (index) = 1
      container.read(queueStateProvider.notifier).playFromQueue(0);

      verify(() => mockPlayerNotifier.skipToAbsoluteIndex(1)).called(1);
    });

    test('playFromRecommended handles invalid index', () {
      final container = createContainer();
      container.read(queueStateProvider.notifier).playFromRecommended(0);
      verifyNever(() => mockPlayerNotifier.skipToAbsoluteIndex(any()));
    });

    test('toggleShuffle shuffles and unshuffles', () async {
      final container = createContainer();
      final tracks = [
        testTrack,
        testTrack.copyWith(id: 't2'),
        testTrack.copyWith(id: 't3'),
      ];

      await container
          .read(queueStateProvider.notifier)
          .playQueue(tracks: tracks, initialIndex: 0);

      container.read(queueStateProvider.notifier).toggleShuffle();
      expect(container.read(queueStateProvider).isShuffled, true);

      // Verify calls to updateNativeQueue
      verify(() => mockPlayerNotifier.updateNativeQueue(any())).called(1);

      container.read(queueStateProvider.notifier).toggleShuffle();
      expect(container.read(queueStateProvider).isShuffled, false);
      expect(
        container
            .read(queueStateProvider)
            .upcomingTracks
            .map((e) => e.track.id),
        ['t2', 't3'],
      );
    });

    test('reorder moves tracks and syncs hardware', () async {
      final container = createContainer();
      final tracks = [
        testTrack,
        testTrack.copyWith(id: 't2'),
        testTrack.copyWith(id: 't3'),
      ];

      await container
          .read(queueStateProvider.notifier)
          .playQueue(tracks: tracks, initialIndex: 0);

      // upcoming: [t2, t3]. Move t3 to top of upcoming.
      container.read(queueStateProvider.notifier).reorder(1, 0);

      expect(
        container.read(queueStateProvider).upcomingTracks[0].track.id,
        't3',
      );
      // hardwareOldIndex = 0 (hist) + 1 (curr) + 1 (oldIdx) = 2
      // hardwareNewIndex = 0 (hist) + 1 (curr) + 0 (newIdx) = 1
      verify(() => mockPlayerNotifier.moveTrack(2, 1)).called(1);
    });

    test('reorder moves tracks forward', () async {
      final container = createContainer();
      final tracks = [
        testTrack,
        testTrack.copyWith(id: 't2'),
        testTrack.copyWith(id: 't3'),
        testTrack.copyWith(id: 't4'),
      ];

      await container
          .read(queueStateProvider.notifier)
          .playQueue(tracks: tracks, initialIndex: 0);

      // upcoming: [t2, t3, t4]. Move t2 to after t3. old=0, new=2 (which becomes 1)
      container.read(queueStateProvider.notifier).reorder(0, 2);

      expect(
        container.read(queueStateProvider).upcomingTracks[0].track.id,
        't3',
      );
      expect(
        container.read(queueStateProvider).upcomingTracks[1].track.id,
        't2',
      );
      verify(() => mockPlayerNotifier.moveTrack(1, 2)).called(1);
    });

    test('addToNextUp handles empty/null response gracefully', () async {
      final container = createContainer();
      when(
        () => mockFetchQueueContextUseCase.call(
          interactionType: 'next_up',
          sourceType: any(named: 'sourceType'),
          sourceId: any(named: 'sourceId'),
        ),
      ).thenThrow(Exception('API Error'));

      await container
          .read(queueStateProvider.notifier)
          .addToNextUp(sourceType: 'album');
      // Should not crash
    });

    test('playFromRecommended skips to correct index', () async {
      final container = createContainer();

      await container
          .read(queueStateProvider.notifier)
          .playQueue(tracks: [testTrack], initialIndex: 0);

      final recItem = QueueItem(
        track: testTrack.copyWith(id: 'rec1'),
        isRecommended: true,
      );
      container.read(queueStateProvider.notifier).state = container
          .read(queueStateProvider)
          .copyWith(upcomingTracks: [recItem]);

      container.read(queueStateProvider.notifier).playFromRecommended(0);

      verify(() => mockPlayerNotifier.skipToAbsoluteIndex(1)).called(1);
    });

    test('reorder handles edge cases and invalid indices', () async {
      final container = createContainer();

      await container
          .read(queueStateProvider.notifier)
          .playQueue(
            tracks: [
              testTrack,
              testTrack.copyWith(id: 't2'),
            ],
            initialIndex: 0,
          );

      container.read(queueStateProvider.notifier).reorder(-1, 0);
      container.read(queueStateProvider.notifier).reorder(0, -1);
      container.read(queueStateProvider.notifier).reorder(10, 0);

      verifyNever(() => mockPlayerNotifier.moveTrack(any(), any()));
    });
  });
}
