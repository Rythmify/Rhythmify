import '../entities/player_state.dart';
import '../repositories/audio_repository.dart';

/// Intent: Provides a [Stream] of [AppPlayerState] to observe playback changes.
///
/// This use case allows the presentation layer to reactively update the UI based
/// on the current status, position, and metadata of the player.
class GetPlayerStateStreamUseCase {
  final AudioRepository repository;
  GetPlayerStateStreamUseCase(this.repository);

  Stream<AppPlayerState> call() {
    return repository.playerStateStream;
  }
}
