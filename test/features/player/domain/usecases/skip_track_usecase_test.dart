import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/skip_track_usecase.dart';

import 'test_helper.dart';

void main() {
  late SkipToNextUseCase skipToNextUseCase;
  late SkipToPreviousUseCase skipToPreviousUseCase;
  late SkipToIndexUseCase skipToIndexUseCase;
  late MockAudioRepository mockRepository;

  setUp(() {
    mockRepository = MockAudioRepository();
    skipToNextUseCase = SkipToNextUseCase(mockRepository);
    skipToPreviousUseCase = SkipToPreviousUseCase(mockRepository);
    skipToIndexUseCase = SkipToIndexUseCase(mockRepository);
  });

  group('SkipToNextUseCase', () {
    test('should skip to next using repository', () async {
      // arrange
      when(() => mockRepository.skipToNext()).thenAnswer((_) async => {});

      // act
      await skipToNextUseCase();

      // assert
      verify(() => mockRepository.skipToNext()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw an exception when repository fails', () async {
      // arrange
      when(() => mockRepository.skipToNext()).thenThrow(Exception());

      // act
      final call = skipToNextUseCase();

      // assert
      expect(() => call, throwsA(isA<Exception>()));
      verify(() => mockRepository.skipToNext()).called(1);
    });
  });

  group('SkipToPreviousUseCase', () {
    test('should skip to previous using repository', () async {
      // arrange
      when(() => mockRepository.skipToPrevious()).thenAnswer((_) async => {});

      // act
      await skipToPreviousUseCase();

      // assert
      verify(() => mockRepository.skipToPrevious()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw an exception when repository fails', () async {
      // arrange
      when(() => mockRepository.skipToPrevious()).thenThrow(Exception());

      // act
      final call = skipToPreviousUseCase();

      // assert
      expect(() => call, throwsA(isA<Exception>()));
      verify(() => mockRepository.skipToPrevious()).called(1);
    });
  });

  group('SkipToIndexUseCase', () {
    const tIndex = 2;
    test('should skip to index using repository', () async {
      // arrange
      when(() => mockRepository.skipToIndex(any())).thenAnswer((_) async => {});

      // act
      await skipToIndexUseCase(tIndex);

      // assert
      verify(() => mockRepository.skipToIndex(tIndex)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw an exception when repository fails', () async {
      // arrange
      when(() => mockRepository.skipToIndex(any())).thenThrow(Exception());

      // act
      final call = skipToIndexUseCase(tIndex);

      // assert
      expect(() => call, throwsA(isA<Exception>()));
      verify(() => mockRepository.skipToIndex(tIndex)).called(1);
    });
  });
}
