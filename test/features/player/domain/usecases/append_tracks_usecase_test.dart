import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/append_tracks_usecase.dart';
import 'test_helper.dart';

void main() {
  late AppendTracksUseCase useCase;
  late MockAudioRepository mockAudioRepository;

  setUp(() {
    mockAudioRepository = MockAudioRepository();
    useCase = AppendTracksUseCase(mockAudioRepository);
  });

  test('should call appendTracks on the repository', () async {
    // arrange
    when(
      () => mockAudioRepository.appendTracks(any()),
    ).thenAnswer((_) async => {});

    // act
    await useCase(dummyTracks);

    // assert
    verify(() => mockAudioRepository.appendTracks(dummyTracks)).called(1);
    verifyNoMoreInteractions(mockAudioRepository);
  });

  test('should throw exception when repository fails', () async {
    // arrange
    when(
      () => mockAudioRepository.appendTracks(any()),
    ).thenThrow(Exception('Failed to append tracks'));

    // act & assert
    expect(() => useCase(dummyTracks), throwsException);
    verify(() => mockAudioRepository.appendTracks(dummyTracks)).called(1);
  });
}
