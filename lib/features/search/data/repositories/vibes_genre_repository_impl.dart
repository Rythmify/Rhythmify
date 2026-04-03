import '../../domain/entities/vibes_genre_content.dart';
import '../../domain/repositories/vibes_genre_repository.dart';
import '../datasources/vibes_genre_remote_datasource.dart';

class GenreRepositoryImpl implements GenreRepository {
  final GenreRemoteSource remoteSource;
  GenreRepositoryImpl({required this.remoteSource});

  @override
  Future<GenreContent> getGenreContent(String genreId) =>
      remoteSource.getGenreContent(genreId);
}
