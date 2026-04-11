import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/foundation.dart';
import '../../data/datasources/home_mock_datasource.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/get_home_data.dart';
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

const bool useMock = true;

final remoteDatasourceProvider = Provider(
  (ref) => HomeRemoteDatasource(dio: apiClient.dio),
);
final mockDatasourceProvider = Provider((ref) => HomeMockDatasource());

final repositoryProvider = Provider((ref) {
  if (useMock) {
    return HomeRepositoryImpl.mock(ref.read(mockDatasourceProvider));
  }
  return HomeRepositoryImpl.remote(ref.read(remoteDatasourceProvider));
});

// ====== Use Case Providers ======

final getHomeDataProvider = Provider(
  (ref) => GetHomeData(ref.read(repositoryProvider)),
);

final getTrendingByGenreProvider = Provider(
  (ref) => GetTrendingByGenre(ref.read(repositoryProvider)),
);

final getHotForYouProvider = Provider(
  (ref) => GetHotForYou(ref.read(repositoryProvider)),
);

final getMoreOfWhatYouLikeUseCaseProvider = Provider(
  (ref) => GetMoreOfWhatYouLike(ref.read(repositoryProvider)),
);

final getMixedForYouUseCaseProvider = Provider(
  (ref) => GetMixedForYou(ref.read(repositoryProvider)),
);

final getDiscoverStationsUseCaseProvider = Provider(
  (ref) => GetDiscoverStations(ref.read(repositoryProvider)),
);

// ====== UI State Providers ======

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final data = await ref.watch(getHomeDataProvider).call();
  debugPrint('mixedForYou count: ${data.mixedForYou.length}');
  debugPrint('moreOfWhatYouLike count: ${data.moreOfWhatYouLike.length}');
  return data;
});

final trendingByGenreProvider = FutureProvider.family<GenreTabTracks, String>((
  ref,
  genreId,
) {
  return ref.watch(getTrendingByGenreProvider).call(genreId);
});

final hotForYouProvider = FutureProvider<HotForYou>((ref) {
  return ref.watch(getHotForYouProvider).call();
});

final moreOfWhatYouLikeProvider = Provider<AsyncValue<List<Track>>>((ref) {
  return ref.watch(homeDataProvider).whenData((h) => h.moreOfWhatYouLike);
});

final mixedForYouProvider = Provider<AsyncValue<List<MixedForYouItem>>>((ref) {
  return ref.watch(homeDataProvider).whenData((h) => h.mixedForYou);
});

final discoverStationsProvider = Provider<AsyncValue<List<DiscoverStation>>>((
  ref,
) {
  return ref.watch(homeDataProvider).whenData((h) => h.discoverWithStations);
});
