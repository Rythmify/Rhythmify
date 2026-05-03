import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/sync_player_state_usecase.dart';
import 'test_helper.dart';

void main() {
  late SyncPlayerStateUseCase useCase;
  late MockPlaybackRepository mockRepository;

  setUp(() {
    mockRepository = MockPlaybackRepository();
    useCase = SyncPlayerStateUseCase(mockRepository);
  });

  const tTrackId = 'track_1';
  final tQueue = [
    {'id': 'track_1', 'title': 'Track 1'},
    {'id': 'track_2', 'title': 'Track 2'},
  ];
  const tPositionSeconds = 45;
  const tVolume = 0.8;

  test('should call syncPlayerState on the repository', () async {
    // arrange
    when(
      () => mockRepository.syncPlayerState(
        trackId: any(named: 'trackId'),
        queue: any(named: 'queue'),
        positionSeconds: any(named: 'positionSeconds'),
        volume: any(named: 'volume'),
      ),
    ).thenAnswer((_) async => {});

    // act
    await useCase(
      trackId: tTrackId,
      queue: tQueue,
      positionSeconds: tPositionSeconds,
      volume: tVolume,
    );

    // assert
    verify(
      () => mockRepository.syncPlayerState(
        trackId: tTrackId,
        queue: tQueue,
        positionSeconds: tPositionSeconds,
        volume: tVolume,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw an exception when repository call fails', () async {
    // arrange
    when(
      () => mockRepository.syncPlayerState(
        trackId: any(named: 'trackId'),
        queue: any(named: 'queue'),
        positionSeconds: any(named: 'positionSeconds'),
        volume: any(named: 'volume'),
      ),
    ).thenThrow(Exception('Sync failed'));

    // act & assert
    expect(
      () => useCase(
        trackId: tTrackId,
        queue: tQueue,
        positionSeconds: tPositionSeconds,
        volume: tVolume,
      ),
      throwsException,
    );
  });
}
