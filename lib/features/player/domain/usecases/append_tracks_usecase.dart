import '../../../../core/domain/entities/track.dart';
import '../repositories/audio_repository.dart';

class AppendTracksUseCase {
  final AudioRepository repository;
  AppendTracksUseCase(this.repository);

  Future<void> call(List<Track> tracks) async {
    return await repository.appendTracks(tracks);
  }
}
