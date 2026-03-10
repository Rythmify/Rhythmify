import '../../../../core/domain/entities/track_summary.dart';
import '../repositories/track_repository.dart';

class GetTrendingTracksByGenre {
  final TrackRepository repository;

  GetTrendingTracksByGenre(this.repository);

  Future<List<TrackSummary>> call(String genre) async {
    if (genre.isEmpty) return await repository.getTrendingTracks();
    return await repository.getTrendingTracksByGenre(genre);
  }
}