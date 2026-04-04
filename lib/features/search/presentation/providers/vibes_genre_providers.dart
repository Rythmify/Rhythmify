import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/vibes_genre_remote_datasource.dart';
import '../../data/repositories/vibes_genre_repository_impl.dart';
import '../../domain/usecases/get_vibes_genre_content.dart';
import '../../domain/entities/vibes_genre_content.dart';
import '../../domain/usecases/get_vibes_genre_trending.dart';
import '../../domain/usecases/get_vibes_genre_playlists.dart';
import '../../domain/usecases/get_vibes_genre_albums.dart';
import '../../../../core/domain/entities/track.dart';

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

final getGenreTracksProvider = Provider(
  (ref) => GetGenreTracks(ref.watch(genreRepositoryProvider)),
);

final getGenrePlaylistsProvider = Provider(
  (ref) => GetGenrePlaylists(ref.watch(genreRepositoryProvider)),
);

final getGenreAlbumsProvider = Provider(
  (ref) => GetGenreAlbums(ref.watch(genreRepositoryProvider)),
);

final genreTracksProvider = FutureProvider.autoDispose
    .family<List<Track>, String>((ref, genreId) {
      return ref.read(getGenreTracksProvider).call(genreId);
    });

final genrePlaylistsProvider = FutureProvider.autoDispose
    .family<List<Map<String, String>>, String>((ref, genreId) {
      return ref.read(getGenrePlaylistsProvider).call(genreId);
    });

final genreAlbumsProvider = FutureProvider.autoDispose
    .family<List<Map<String, String>>, String>((ref, genreId) {
      return ref.read(getGenreAlbumsProvider).call(genreId);
    });
