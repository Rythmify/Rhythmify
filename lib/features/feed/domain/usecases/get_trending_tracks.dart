import '../repositories/home_repository.dart';
import '../entities/genre_tab_tracks.dart';

class GetTrendingByGenre {
  final HomeRepository repository;

  GetTrendingByGenre(this.repository);

  Future<GenreTabTracks> call(String genreId) =>
      repository.getTrendingByGenre(genreId);
}
