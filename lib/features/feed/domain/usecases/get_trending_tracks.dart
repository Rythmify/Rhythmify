import '../repositories/home_repository.dart';
import '../entities/genre_tab_tracks.dart';

/// Use case for getting trending tracks
class GetTrendingByGenre {
  final HomeRepository repository;

  GetTrendingByGenre(this.repository);

  /// Executes the use case, returning a list of trending tracks
  Future<GenreTabTracks> call(String genreId) =>
      repository.getTrendingByGenre(genreId);
}
