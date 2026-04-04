import '../repositories/vibes_genre_repository.dart';

class GetGenrePlaylists {
  final GenreRepository repository;
  GetGenrePlaylists(this.repository);

  Future<List<Map<String, String>>> call(String genreId) =>
      repository.getGenrePlaylists(genreId);
}
