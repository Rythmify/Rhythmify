import '../../../../core/domain/entities/track.dart';
import '../entities/vibes_genre_content.dart';

abstract class GenreRepository {
  Future<GenreContent> getGenreContent(String genreId);
  Future<List<Track>> getGenreTrendingTracks(String genreId);
  Future<List<Map<String, String>>> getGenrePlaylists(String genreId);
  Future<List<Map<String, String>>> getGenreAlbums(String genreId);
}
