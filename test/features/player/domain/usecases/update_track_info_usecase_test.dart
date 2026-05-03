import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/update_track_info_usecase.dart';
import 'test_helper.dart';

void main() {
  setUpAll(() {
    registerTestFallbackValues();
  });

  late UpdateTrackInfoUseCase useCase;
  late MockAudioRepository mockRepository;

  setUp(() {
    mockRepository = MockAudioRepository();
    useCase = UpdateTrackInfoUseCase(mockRepository);
  });

  const tId = '1';

  test('should call updateTrackInfo on the repository', () async {
    // arrange
    when(
      () => mockRepository.updateTrackInfo(any(), any()),
    ).thenAnswer((_) async => {});

    // act
    await useCase(tId, dummyTrack);

    // assert
    verify(() => mockRepository.updateTrackInfo(tId, dummyTrack)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw an exception when repository call fails', () async {
    // arrange
    when(
      () => mockRepository.updateTrackInfo(any(), any()),
    ).thenThrow(Exception('Update failed'));

    // act & assert
    expect(() => useCase(tId, dummyTrack), throwsException);
  });
}
