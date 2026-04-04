import '../../domain/entities/vibes_genre_content.dart';
import '../../domain/repositories/vibes_genre_repository.dart';
import '../datasources/vibes_genre_remote_datasource.dart';
import '../../../../core/domain/entities/track.dart';

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
  Future<List<Map<String, String>>> getGenrePlaylists(String genreId) =>
      remoteSource.getGenrePlaylists(genreId);

  @override
  Future<List<Map<String, String>>> getGenreAlbums(String genreId) =>
      remoteSource.getGenreAlbums(genreId);
}
