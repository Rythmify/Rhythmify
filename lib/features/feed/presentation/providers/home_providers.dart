// coverage:ignore-file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../data/datasources/home_mock_datasource.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/get_home_data.dart';
import '../../domain/usecases/get_mix_tracks.dart';
import '../../domain/usecases/get_related_tracks.dart';
import '../../domain/usecases/get_trending_tracks.dart';
import '../../domain/usecases/get_hot_tracks.dart';
import '../../domain/usecases/get_more__you_like.dart';
import '../../domain/usecases/get_mixed_playlists.dart';
import '../../domain/usecases/get_discover_stations.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/network/api_client.dart';

/// Flag to switch between mock and remote data sources globally.
///
/// Set to `true` during development to use [HomeMockDatasource] instead
/// of making real network requests.
const bool useMock = false;

/// Provides the remote home datasource backed by the shared [apiClient].
final remoteDatasourceProvider = Provider(
  (ref) => HomeRemoteDatasource(dio: apiClient.dio),
);

/// Provides the mock home datasource for development and testing.
final mockDatasourceProvider = Provider((ref) => HomeMockDatasource());

/// Provides the [HomeRepositoryImpl], selecting mock or remote based on [useMock].
final repositoryProvider = Provider((ref) {
  if (useMock) {
    return HomeRepositoryImpl.mock(ref.read(mockDatasourceProvider));
  }
  return HomeRepositoryImpl.remote(ref.read(remoteDatasourceProvider));
});

// ====== Use Case Providers ======

/// Provides the [GetHomeData] use case.
final getHomeDataProvider = Provider(
  (ref) => GetHomeData(ref.read(repositoryProvider)),
);

/// Provides the [GetTrendingByGenre] use case.
final getTrendingByGenreProvider = Provider(
  (ref) => GetTrendingByGenre(ref.read(repositoryProvider)),
);

/// Provides the [GetHotForYou] use case.
final getHotForYouProvider = Provider(
  (ref) => GetHotForYou(ref.read(repositoryProvider)),
);

/// Provides the [GetMoreOfWhatYouLike] use case.
final getMoreOfWhatYouLikeUseCaseProvider = Provider(
  (ref) => GetMoreOfWhatYouLike(ref.read(repositoryProvider)),
);

/// Provides the [GetMixedForYou] use case.
final getMixedForYouUseCaseProvider = Provider(
  (ref) => GetMixedForYou(ref.read(repositoryProvider)),
);

/// Provides the [GetDiscoverStations] use case.
final getDiscoverStationsUseCaseProvider = Provider(
  (ref) => GetDiscoverStations(ref.read(repositoryProvider)),
);

// ====== UI State Providers ======

/// Fetches and exposes the full home screen data as an async state.
///
/// Drives the majority of the home screen UI. Invalidating this provider
/// triggers a full home screen refresh.
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final data = await ref.watch(getHomeDataProvider).call();
  debugPrint('mixedForYou count: ${data.mixedForYou.length}');
  debugPrint('moreOfWhatYouLike count: ${data.moreOfWhatYouLike.length}');
  return data;
});

/// Fetches trending tracks for the given genre ID as an async state.
final trendingByGenreProvider = FutureProvider.family<GenreTabTracks, String>((
  ref,
  genreId,
) {
  return ref.watch(getTrendingByGenreProvider).call(genreId);
});

/// Fetches the "Hot For You" section as an async state.
final hotForYouProvider = FutureProvider<HotForYou>((ref) {
  return ref.watch(getHotForYouProvider).call();
});

/// Derives the "More Of What You Like" track list from [homeDataProvider].
final moreOfWhatYouLikeProvider = Provider<AsyncValue<List<Track>>>((ref) {
  return ref.watch(homeDataProvider).whenData((h) => h.moreOfWhatYouLike);
});

/// Derives the "Mixed For You" item list from [homeDataProvider].
final mixedForYouProvider = Provider<AsyncValue<List<MixedForYouItem>>>((ref) {
  return ref.watch(homeDataProvider).whenData((h) => h.mixedForYou);
});

/// Derives the discover stations list from [homeDataProvider].
final discoverStationsProvider = Provider<AsyncValue<List<DiscoverStation>>>((
  ref,
) {
  return ref.watch(homeDataProvider).whenData((h) => h.discoverWithStations);
});

/// Provides the [GetMixTracks] use case.
final getMixTracksUseCaseProvider = Provider(
  (ref) => GetMixTracks(ref.read(repositoryProvider)),
);

/// Fetches the track list for a given mix ID.
///
/// Auto-disposed when no longer watched.
final mixTracksProvider = FutureProvider.autoDispose
    .family<List<Track>, String>(
      (ref, mixId) => ref.read(getMixTracksUseCaseProvider).call(mixId),
    );

/// Provides the [GetRelatedTracks] use case.
final getRelatedTracksUseCaseProvider = Provider(
  (ref) => GetRelatedTracks(ref.read(repositoryProvider)),
);

/// Fetches tracks related to a given track ID.
///
/// Auto-disposed when no longer watched.
final relatedTracksProvider = FutureProvider.autoDispose
    .family<List<Track>, String>(
      (ref, trackId) => ref.read(getRelatedTracksUseCaseProvider).call(trackId),
    );
