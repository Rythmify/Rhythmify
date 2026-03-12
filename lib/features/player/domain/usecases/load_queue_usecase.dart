import '../../../../core/domain/entities/track_summary.dart';
import '../repositories/audio_repository.dart';

class LoadQueueUseCase {
  final AudioRepository repository;
  LoadQueueUseCase(this.repository);

  Future<void> call(List<TrackSummary> tracks, {int initialIndex = 0}) async {
    return await repository.loadQueue(tracks, initialIndex: initialIndex);
  }
}