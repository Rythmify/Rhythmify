import '../repositories/vibes_genre_repository.dart';
import '../entities/vibes_genre_album.dart';

/// Use case that fetches albums for specific genre
class GetGenreAlbums {
  final GenreRepository repository;
  GetGenreAlbums(this.repository);

  Future<List<GenreAlbum>> call(String genreId) =>
      repository.getGenreAlbums(genreId);
}
