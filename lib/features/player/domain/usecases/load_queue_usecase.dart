import '../../../../core/domain/entities/track.dart';
import '../repositories/audio_repository.dart';

class LoadQueueUseCase {
  final AudioRepository repository;
  LoadQueueUseCase(this.repository);

  Future<void> call(List<Track> tracks, {int initialIndex = 0}) async {
    return await repository.loadQueue(tracks, initialIndex: initialIndex);
  }
}
