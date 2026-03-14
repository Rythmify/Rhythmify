import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track_summary.dart';

class GetHotTracks {
  final HomeRepository repository;

  GetHotTracks(this.repository);

  Future<List<TrackSummary>> call() {
    return repository.getHotTracks();
  }
}
