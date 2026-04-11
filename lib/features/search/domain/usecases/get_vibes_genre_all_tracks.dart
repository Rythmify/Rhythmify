import '../../../../core/domain/entities/track.dart';
import '../repositories/vibes_genre_repository.dart';

/// Use case that fetches tracks for genre
class GetGenreAllTracks {
  final GenreRepository repository;
  GetGenreAllTracks(this.repository);

  Future<List<Track>> call(String genreId) =>
      repository.getGenreAllTracks(genreId);
}
