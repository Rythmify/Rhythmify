import '../repositories/vibes_genre_repository.dart';

class GetGenreAlbums {
  final GenreRepository repository;
  GetGenreAlbums(this.repository);

  Future<List<Map<String, String>>> call(String genreId) =>
      repository.getGenreAlbums(genreId);
}
