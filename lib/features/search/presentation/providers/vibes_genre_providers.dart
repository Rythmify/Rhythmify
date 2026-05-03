import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/vibes_genre_remote_datasource.dart';
import '../../data/repositories/vibes_genre_repository_impl.dart';
import '../../domain/usecases/get_vibes_genre_content.dart';
import '../../domain/usecases/get_vibes_genre_trending.dart';
import '../../domain/usecases/get_vibes_genre_playlists.dart';
import '../../domain/usecases/get_vibes_genre_albums.dart';
import '../../domain/usecases/get_vibes_genre_artists.dart';
import '../../domain/usecases/get_vibes_genre_all_tracks.dart';
import '../../domain/entities/vibes_genre_content.dart';
import '../../domain/entities/vibes_genre_playlist.dart';
import '../../domain/entities/vibes_genre_album.dart';
import '../../domain/entities/vibes_genre_artists.dart';
import '../../../../core/domain/entities/track.dart';
import '../../data/datasources/vibes_genre_mock_datasource.dart';
import '../../../../core/network/api_client.dart';
// now has Impl

// ── Dependency graph ──────────────────────────────────────────────────────────
const bool _useMock = false;

final genreRemoteSourceProvider = Provider<GenreRemoteSource>((ref) {
  if (_useMock) return GenreRemoteSourceMock();
  return GenreRemoteSourceImpl(dio: apiClient.dio);
});

/// Provides the mock data source. Swap to a real HTTP source at integration time.

/// Provides the repository, injecting the remote source.
final genreRepositoryProvider = Provider(
  (ref) =>
      GenreRepositoryImpl(remoteSource: ref.watch(genreRemoteSourceProvider)),
);

// ── Use case providers ────────────────────────────────────────────────────────

final getGenreContentProvider = Provider(
  (ref) => GetGenreContent(ref.watch(genreRepositoryProvider)),
);

final getGenreTracksProvider = Provider(
  (ref) => GetGenreTracks(ref.watch(genreRepositoryProvider)),
);

final getGenrePlaylistsProvider = Provider(
  (ref) => GetGenrePlaylists(ref.watch(genreRepositoryProvider)),
);

final getGenreAlbumsProvider = Provider(
  (ref) => GetGenreAlbums(ref.watch(genreRepositoryProvider)),
);

final getGenreArtistsProvider = Provider(
  (ref) => GetGenreArtists(ref.watch(genreRepositoryProvider)),
);

final getGenreAllTracksProvider = Provider(
  (ref) => GetGenreAllTracks(ref.watch(genreRepositoryProvider)),
);

/// Fetches the full [GenreContent] bundle for the genre page.
final genreContentProvider = FutureProvider.autoDispose
    .family<GenreContent, String>((ref, genreId) {
      return ref.read(getGenreContentProvider).call(genreId);
    });

/// Fetches trending tracks for the Trending tab.
final genreTracksProvider = FutureProvider.autoDispose
    .family<List<Track>, String>((ref, genreId) {
      return ref.read(getGenreTracksProvider).call(genreId);
    });

/// Fetches playlists for the Playlists tab.
final genrePlaylistsProvider = FutureProvider.autoDispose
    .family<List<GenrePlaylist>, String>((ref, genreId) {
      return ref.read(getGenrePlaylistsProvider).call(genreId);
    });

/// Fetches albums for the Albums tab.
final genreAlbumsProvider = FutureProvider.autoDispose
    .family<List<GenreAlbum>, String>((ref, genreId) {
      return ref.read(getGenreAlbumsProvider).call(genreId);
    });

/// Fetches artists associated with the genre.
final genreArtistsProvider = FutureProvider.autoDispose
    .family<List<GenreArtist>, String>((ref, genreId) {
      return ref.read(getGenreArtistsProvider).call(genreId);
    });

/// Fetches all tracks for the See All tracks page.
final genreAllTracksProvider = FutureProvider.autoDispose
    .family<List<Track>, String>((ref, genreId) {
      return ref.read(getGenreAllTracksProvider).call(genreId);
    });
