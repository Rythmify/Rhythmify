import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/seek_position_usecase.dart';

import 'test_helper.dart';

void main() {
  setUpAll(() {
    registerTestFallbackValues();
  });

  late SeekPositionUseCase useCase;
  late MockAudioRepository mockRepository;

  setUp(() {
    mockRepository = MockAudioRepository();
    useCase = SeekPositionUseCase(mockRepository);
  });

  const tPosition = Duration(seconds: 30);

  test('should seek to position using repository', () async {
    // arrange
    when(() => mockRepository.seek(any())).thenAnswer((_) async => {});

    // act
    await useCase(tPosition);

    // assert
    verify(() => mockRepository.seek(tPosition)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw an exception when repository fails', () async {
    // arrange
    when(
      () => mockRepository.seek(any()),
    ).thenAnswer((_) async => throw Exception());

    // act & assert
    expect(useCase(tPosition), throwsA(isA<Exception>()));
    verify(() => mockRepository.seek(tPosition)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
