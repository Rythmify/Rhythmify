import '../../../../core/domain/entities/track.dart';
import '../repositories/audio_repository.dart';

/// Intent: Updates the metadata of a specific track in the playback queue.
///
/// This use case synchronizes external track data changes with the current
/// playback session.
class UpdateTrackInfoUseCase {
  final AudioRepository repository;

  UpdateTrackInfoUseCase(this.repository);

  Future<void> call(String id, Track updatedTrack) async {
    return await repository.updateTrackInfo(id, updatedTrack);
  }
}
