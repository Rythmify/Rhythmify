import '../../../../core/domain/entities/track.dart';
import '../entities/vibes_genre_content.dart';
import '../entities/vibes_genre_playlist.dart';
import '../entities/vibes_genre_album.dart';
import '../entities/vibes_genre_artists.dart';

/// Domain contract for the genre/vibes feature.
/// Defines the operations the presentation layer can request — implementation lives in the data layer.
abstract class GenreRepository {
  /// Returns the full content bundle for a genre page.
  Future<GenreContent> getGenreContent(String genreId);

  /// Returns trending tracks for the given [genreId].
  Future<List<Track>> getGenreTrendingTracks(String genreId);

  /// Returns playlists tagged under the given [genreId].
  Future<List<GenrePlaylist>> getGenrePlaylists(String genreId);

  /// Returns albums released under the given [genreId].
  Future<List<GenreAlbum>> getGenreAlbums(String genreId);

  /// Returns artists associated with the given [genreId].
  Future<List<GenreArtist>> getGenreArtists(String genreId);

  /// Returns all tracks for the given [genreId] (used by the See All page).
  Future<List<Track>> getGenreAllTracks(String genreId);
}
