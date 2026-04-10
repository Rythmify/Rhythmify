import '../repositories/vibes_genre_repository.dart';
import '../entities/vibes_genre_artists.dart';

/// Use case that fetches the artists list for a given genre from [GenreRepository].
class GetGenreArtists {
  final GenreRepository repository;
  GetGenreArtists(this.repository);

  Future<List<GenreArtist>> call(String genreId) =>
      repository.getGenreArtists(genreId);
}
