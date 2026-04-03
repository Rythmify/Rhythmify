import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/vibes_genre_remote_datasource.dart';
import '../../data/repositories/vibes_genre_repository_impl.dart';
import '../../domain/usecases/get_vibes_genre_content.dart';
import '../../domain/entities/vibes_genre_content.dart';

final genreRemoteSourceProvider = Provider<GenreRemoteSource>(
  (_) => GenreRemoteSourceMock(),
);

final genreRepositoryProvider = Provider(
  (ref) =>
      GenreRepositoryImpl(remoteSource: ref.watch(genreRemoteSourceProvider)),
);

final getGenreContentProvider = Provider(
  (ref) => GetGenreContent(ref.watch(genreRepositoryProvider)),
);

final genreContentProvider = FutureProvider.autoDispose
    .family<GenreContent, String>((ref, genreId) async {
      return ref.read(getGenreContentProvider).call(genreId);
    });
