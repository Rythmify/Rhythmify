import '../../../../core/domain/entities/track.dart';
import '../entities/vibes_genre_content.dart';
import '../entities/vibes_genre_playlist.dart';
import '../entities/vibes_genre_album.dart';
import '../entities/vibes_genre_artists.dart';

abstract class GenreRepository {
  Future<GenreContent> getGenreContent(String genreId);
  Future<List<Track>> getGenreTrendingTracks(String genreId);
  Future<List<GenrePlaylist>> getGenrePlaylists(String genreId);
  Future<List<GenreAlbum>> getGenreAlbums(String genreId);
  Future<List<GenreArtist>> getGenreArtists(String genreId);
  Future<List<Track>> getGenreAllTracks(String genreId);
}
