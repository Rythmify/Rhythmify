import '../repositories/vibes_genre_repository.dart';
import '../entities/vibes_genre_playlist.dart';

/// Use case that fetches playlists for genre
class GetGenrePlaylists {
  final GenreRepository repository;
  GetGenrePlaylists(this.repository);

  Future<List<GenrePlaylist>> call(String genreId) =>
      repository.getGenrePlaylists(genreId);
}
