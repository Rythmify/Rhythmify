import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/fetch_queue_context_usecase.dart';
import 'test_helper.dart';

void main() {
  late FetchQueueContextUseCase useCase;
  late MockPlaybackRepository mockPlaybackRepository;

  setUp(() {
    mockPlaybackRepository = MockPlaybackRepository();
    useCase = FetchQueueContextUseCase(mockPlaybackRepository);
  });

  const tInteractionType = 'play';
  const tSourceType = 'playlist';
  const tSourceId = 'playlist123';
  const tTargetUserId = 'user456';
  final tResult = {'tracks': []};

  test('should call fetchQueueContext on the repository', () async {
    // arrange
    when(
      () => mockPlaybackRepository.fetchQueueContext(
        interactionType: any(named: 'interactionType'),
        sourceType: any(named: 'sourceType'),
        sourceId: any(named: 'sourceId'),
        targetUserId: any(named: 'targetUserId'),
      ),
    ).thenAnswer((_) async => tResult);

    // act
    final result = await useCase(
      interactionType: tInteractionType,
      sourceType: tSourceType,
      sourceId: tSourceId,
      targetUserId: tTargetUserId,
    );

    // assert
    expect(result, tResult);
    verify(
      () => mockPlaybackRepository.fetchQueueContext(
        interactionType: tInteractionType,
        sourceType: tSourceType,
        sourceId: tSourceId,
        targetUserId: tTargetUserId,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockPlaybackRepository);
  });

  test('should throw exception when repository fails', () async {
    // arrange
    when(
      () => mockPlaybackRepository.fetchQueueContext(
        interactionType: any(named: 'interactionType'),
        sourceType: any(named: 'sourceType'),
        sourceId: any(named: 'sourceId'),
        targetUserId: any(named: 'targetUserId'),
      ),
    ).thenThrow(Exception('Failed to fetch queue context'));

    // act & assert
    expect(
      () => useCase(interactionType: tInteractionType, sourceType: tSourceType),
      throwsException,
    );
  });
}
