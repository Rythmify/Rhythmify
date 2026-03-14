import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track_summary.dart';

class GetTrendingTracks {
  final HomeRepository repository;

  GetTrendingTracks(this.repository);

  Future<List<TrackSummary>> call(String genre) {
    return repository.getTrendingTracks(genre);
  }
}
