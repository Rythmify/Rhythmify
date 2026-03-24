import '../../../../core/domain/entities/track.dart';
import '../repositories/audio_repository.dart';

/// Intent: Loads a specific list of tracks into the player's playback queue.
///
/// This use case replaces the current queue with a new one and starts playback
/// from the specified [initialIndex].
class LoadQueueUseCase {
  final AudioRepository repository;
  LoadQueueUseCase(this.repository);

  Future<void> call(List<Track> tracks, {int initialIndex = 0}) async {
    return await repository.loadQueue(tracks, initialIndex: initialIndex);
  }
}
