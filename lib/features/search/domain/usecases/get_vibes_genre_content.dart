import '../entities/vibes_genre_content.dart';
import '../repositories/vibes_genre_repository.dart';

class GetGenreContent {
  final GenreRepository repository;
  GetGenreContent(this.repository);

  Future<GenreContent> call(String genreId) =>
      repository.getGenreContent(genreId);
}
