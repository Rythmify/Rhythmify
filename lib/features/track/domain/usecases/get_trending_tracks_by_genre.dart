import '../../../../core/domain/entities/track.dart';
import '../repositories/track_repository.dart';

class GetTrendingTracksByGenre {
  final TrackRepository repository;

  GetTrendingTracksByGenre(this.repository);

  Future<List<Track>> call(String genre) async {
    if (genre.isEmpty) return await repository.getTrendingTracks();
    return await repository.getTrendingTracksByGenre(genre);
  }
}