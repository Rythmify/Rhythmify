import '../../../../core/domain/entities/track.dart';
import '../repositories/audio_repository.dart';

class UpdateTrackInfoUseCase {
  final AudioRepository repository;

  UpdateTrackInfoUseCase(this.repository);

  Future<void> call(String id, Track updatedTrack) async {
    return await repository.updateTrackInfo(id, updatedTrack);
  }
}
