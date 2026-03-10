import '../../../../core/domain/entities/track_summary.dart';
import '../repositories/track_repository.dart';

class GetTrendingTracks {
  final TrackRepository repository;

  GetTrendingTracks(this.repository);

  Future<List<TrackSummary>> call() async {
    return await repository.getTrendingTracks();
  }
}