import '../entities/player_state.dart';
import '../repositories/audio_repository.dart';

class GetPlayerStateStreamUseCase {
  final AudioRepository repository;
  GetPlayerStateStreamUseCase(this.repository);

  Stream<AppPlayerState> call() {
    return repository.playerStateStream;
  }
}
