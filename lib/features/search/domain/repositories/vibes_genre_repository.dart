import '../entities/vibes_genre_content.dart';

abstract class GenreRepository {
  Future<GenreContent> getGenreContent(String genreId);
}
