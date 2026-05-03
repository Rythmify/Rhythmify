import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/load_queue_usecase.dart';
import 'test_helper.dart';

void main() {
  late LoadQueueUseCase useCase;
  late MockAudioRepository mockAudioRepository;

  setUp(() {
    mockAudioRepository = MockAudioRepository();
    useCase = LoadQueueUseCase(mockAudioRepository);
  });

  test('should load queue with default initialIndex', () async {
    // arrange
    when(
      () => mockAudioRepository.loadQueue(
        any(),
        initialIndex: any(named: 'initialIndex'),
      ),
    ).thenAnswer((_) async => {});

    // act
    await useCase(dummyTracks);

    // assert
    verify(
      () => mockAudioRepository.loadQueue(dummyTracks, initialIndex: 0),
    ).called(1);
    verifyNoMoreInteractions(mockAudioRepository);
  });

  test('should load queue with custom initialIndex', () async {
    // arrange
    const tIndex = 1;
    when(
      () => mockAudioRepository.loadQueue(
        any(),
        initialIndex: any(named: 'initialIndex'),
      ),
    ).thenAnswer((_) async => {});

    // act
    await useCase(dummyTracks, initialIndex: tIndex);

    // assert
    verify(
      () => mockAudioRepository.loadQueue(dummyTracks, initialIndex: tIndex),
    ).called(1);
    verifyNoMoreInteractions(mockAudioRepository);
  });

  test('should throw exception when repository fails', () async {
    // arrange
    when(
      () => mockAudioRepository.loadQueue(
        any(),
        initialIndex: any(named: 'initialIndex'),
      ),
    ).thenThrow(Exception('Failed to load queue'));

    // act & assert
    expect(() => useCase(dummyTracks), throwsException);
    verify(
      () => mockAudioRepository.loadQueue(dummyTracks, initialIndex: 0),
    ).called(1);
  });
}
