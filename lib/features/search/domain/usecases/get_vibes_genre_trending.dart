import '../../../../core/domain/entities/track.dart';
import '../repositories/vibes_genre_repository.dart';

class GetGenreTracks {
  final GenreRepository repository;
  GetGenreTracks(this.repository);

  Future<List<Track>> call(String genreId) =>
      repository.getGenreTrendingTracks(genreId);
}
