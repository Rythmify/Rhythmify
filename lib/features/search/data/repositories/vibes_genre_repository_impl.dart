import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/vibes_genre_content.dart';
import '../../domain/entities/vibes_genre_playlist.dart';
import '../../domain/entities/vibes_genre_album.dart';
import '../../domain/entities/vibes_genre_artists.dart';
import '../../domain/repositories/vibes_genre_repository.dart';
import '../datasources/vibes_genre_remote_datasource.dart';

class GenreRepositoryImpl implements GenreRepository {
  final GenreRemoteSource remoteSource;
  GenreRepositoryImpl({required this.remoteSource});

  @override
  Future<GenreContent> getGenreContent(String genreId) =>
      remoteSource.getGenreContent(genreId);

  @override
  Future<List<Track>> getGenreTrendingTracks(String genreId) =>
      remoteSource.getGenreTrendingTracks(genreId);

  @override
  Future<List<GenrePlaylist>> getGenrePlaylists(String genreId) =>
      remoteSource.getGenrePlaylists(genreId);

  @override
  Future<List<GenreAlbum>> getGenreAlbums(String genreId) =>
      remoteSource.getGenreAlbums(genreId);

  @override
  Future<List<GenreArtist>> getGenreArtists(String genreId) =>
      remoteSource.getGenreArtists(genreId);

  @override
  Future<List<Track>> getGenreAllTracks(String genreId) =>
      remoteSource.getGenreAllTracks(genreId);
}
