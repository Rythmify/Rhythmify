import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/domain/usecases/get_player_state_stream_usecase.dart';
import 'test_helper.dart';

void main() {
  late GetPlayerStateStreamUseCase useCase;
  late MockAudioRepository mockAudioRepository;

  setUp(() {
    mockAudioRepository = MockAudioRepository();
    useCase = GetPlayerStateStreamUseCase(mockAudioRepository);
  });

  test(
    'should return a stream of AppPlayerState from the repository',
    () async {
      // arrange
      final tStream = Stream.fromIterable([dummyPlayerState]);
      when(
        () => mockAudioRepository.playerStateStream,
      ).thenAnswer((_) => tStream);

      // act
      final result = useCase();

      // assert
      expect(result, tStream);
      verify(() => mockAudioRepository.playerStateStream).called(1);
      verifyNoMoreInteractions(mockAudioRepository);
    },
  );
}
