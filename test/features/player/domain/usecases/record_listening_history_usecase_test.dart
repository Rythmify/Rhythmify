import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/record_listening_history_usecase.dart';
import 'package:rythmify/features/player/domain/entities/history_record.dart';
import 'test_helper.dart';

void main() {
  late RecordListeningHistoryUseCase useCase;
  late MockPlaybackRepository mockPlaybackRepository;

  setUp(() {
    mockPlaybackRepository = MockPlaybackRepository();
    useCase = RecordListeningHistoryUseCase(mockPlaybackRepository);
    registerFallbackValue(dummyHistoryRecord);
  });

  test(
    'should call recordListeningHistory on the repository when duration > 0',
    () async {
      // arrange
      when(
        () => mockPlaybackRepository.recordListeningHistory(any()),
      ).thenAnswer((_) async => {});

      // act
      await useCase(dummyHistoryRecord);

      // assert
      verify(
        () => mockPlaybackRepository.recordListeningHistory(dummyHistoryRecord),
      ).called(1);
      verifyNoMoreInteractions(mockPlaybackRepository);
    },
  );

  test('should NOT call recordListeningHistory when duration <= 0', () async {
    // arrange
    final invalidRecord = HistoryRecord(
      trackId: '1',
      playedAt: DateTime.now(),
      durationPlayedSeconds: 0,
    );

    // act
    await useCase(invalidRecord);

    // assert
    verifyNever(() => mockPlaybackRepository.recordListeningHistory(any()));
  });

  test('should throw exception when repository fails', () async {
    // arrange
    when(
      () => mockPlaybackRepository.recordListeningHistory(any()),
    ).thenThrow(Exception('Failed to record history'));

    // act & assert
    expect(() => useCase(dummyHistoryRecord), throwsException);
    verify(
      () => mockPlaybackRepository.recordListeningHistory(dummyHistoryRecord),
    ).called(1);
  });
}
