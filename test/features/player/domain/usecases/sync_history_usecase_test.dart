import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/sync_history_usecase.dart';

import 'test_helper.dart';

void main() {
  late SyncHistoryUseCase useCase;
  late MockPlaybackRepository mockRepository;

  setUp(() {
    mockRepository = MockPlaybackRepository();
    useCase = SyncHistoryUseCase(mockRepository);
  });

  test('should sync pending history using repository', () async {
    // arrange
    when(() => mockRepository.syncPendingHistory()).thenAnswer((_) async => {});

    // act
    await useCase();

    // assert
    verify(() => mockRepository.syncPendingHistory()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw an exception when repository fails', () async {
    // arrange
    when(
      () => mockRepository.syncPendingHistory(),
    ).thenAnswer((_) async => throw Exception());

    // act & assert
    expect(useCase(), throwsA(isA<Exception>()));
    verify(() => mockRepository.syncPendingHistory()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
