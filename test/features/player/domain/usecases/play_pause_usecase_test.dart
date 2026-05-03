import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/play_pause_usecase.dart';
import 'test_helper.dart';

void main() {
  late MockAudioRepository mockAudioRepository;
  late PlayTrackUseCase playUseCase;
  late PauseTrackUseCase pauseUseCase;

  setUp(() {
    mockAudioRepository = MockAudioRepository();
    playUseCase = PlayTrackUseCase(mockAudioRepository);
    pauseUseCase = PauseTrackUseCase(mockAudioRepository);
  });

  group('PlayTrackUseCase', () {
    test('should call play on the repository', () async {
      // arrange
      when(() => mockAudioRepository.play()).thenAnswer((_) async => {});

      // act
      await playUseCase();

      // assert
      verify(() => mockAudioRepository.play()).called(1);
      verifyNoMoreInteractions(mockAudioRepository);
    });

    test('should throw exception when play fails', () async {
      // arrange
      when(
        () => mockAudioRepository.play(),
      ).thenThrow(Exception('Failed to play'));

      // act & assert
      expect(() => playUseCase(), throwsException);
      verify(() => mockAudioRepository.play()).called(1);
    });
  });

  group('PauseTrackUseCase', () {
    test('should call pause on the repository', () async {
      // arrange
      when(() => mockAudioRepository.pause()).thenAnswer((_) async => {});

      // act
      await pauseUseCase();

      // assert
      verify(() => mockAudioRepository.pause()).called(1);
      verifyNoMoreInteractions(mockAudioRepository);
    });

    test('should throw exception when pause fails', () async {
      // arrange
      when(
        () => mockAudioRepository.pause(),
      ).thenThrow(Exception('Failed to pause'));

      // act & assert
      expect(() => pauseUseCase(), throwsException);
      verify(() => mockAudioRepository.pause()).called(1);
    });
  });
}
