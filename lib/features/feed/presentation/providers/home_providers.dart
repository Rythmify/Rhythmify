import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/home_datasource.dart';
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
import 'package:http/http.dart' as http;

// ====================
//  --- The Switch ---
// ====================
const bool _useMock = true;

final datasourceProvider = Provider(
  (ref) => HomeDatasource(
    client: http.Client(),
    baseUrl:
        'https://rythmify-backend-dev.livelypebble-6b7965ef.uaenorth.azurecontainerapps.io/api/v1',
    mockOnly: _useMock,
  ),
);

final repositoryProvider = Provider(
  (ref) => HomeRepositoryImpl(ref.read(datasourceProvider)),
);

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

final homeDataProvider = FutureProvider<HomeData>((ref) {
  return ref.watch(getHomeDataProvider).call();
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

final moreOfWhatYouLikeProvider = FutureProvider<List<Track>>((ref) {
  return ref.watch(getMoreOfWhatYouLikeUseCaseProvider).call();
});

final mixedForYouProvider = FutureProvider<List<MixedForYouItem>>((ref) {
  return ref.watch(getMixedForYouUseCaseProvider).call();
});

final discoverStationsProvider = FutureProvider<List<DiscoverStation>>((ref) {
  return ref.watch(getDiscoverStationsUseCaseProvider).call();
});
