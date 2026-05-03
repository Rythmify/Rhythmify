import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/initiate_playback_usecase.dart';

import 'test_helper.dart';

void main() {
  late InitiatePlaybackUseCase useCase;
  late MockPlaybackRepository mockRepository;

  setUp(() {
    mockRepository = MockPlaybackRepository();
    useCase = InitiatePlaybackUseCase(mockRepository);
  });

  const tTrackId = '1';
  const tResponse = 'success';

  test(
    'should initiate playback and return response from repository',
    () async {
      // arrange
      when(
        () => mockRepository.initiatePlayback(any()),
      ).thenAnswer((_) async => tResponse);

      // act
      final result = await useCase(tTrackId);

      // assert
      expect(result, tResponse);
      verify(() => mockRepository.initiatePlayback(tTrackId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should throw an exception when repository fails', () async {
    // arrange
    when(
      () => mockRepository.initiatePlayback(any()),
    ).thenAnswer((_) async => throw Exception());

    // act & assert
    expect(useCase(tTrackId), throwsA(isA<Exception>()));
    verify(() => mockRepository.initiatePlayback(tTrackId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
