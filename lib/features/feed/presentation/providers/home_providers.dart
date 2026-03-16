import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/feed/domain/usecases/get_more__you_like.dart';

import '../../../feed/data/datasources/home_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';

import '../../domain/usecases/get_trending_tracks.dart';
import '../../domain/usecases/get_hot_tracks.dart';
import '../../domain/usecases/get_mixed_playlists.dart';
import '../../domain/usecases/get_discover_stations.dart';

import '../../../../core/domain/entities/track_summary.dart';

//responsible for fetching all home-related data
final datasourceProvider = Provider((ref) => HomeDatasource());

//createsrepository using the datasource
final repositoryProvider = Provider(
  (ref) => HomeRepositoryImpl(ref.read(datasourceProvider)),
);

//======usecase providers======

//trending tracks
final getTrendingTracksProvider = Provider(
  (ref) => GetTrendingTracks(ref.read(repositoryProvider)),
);

//hot tracks
final getHotTracksProvider = Provider(
  (ref) => GetHotTracks(ref.read(repositoryProvider)),
);

//Mixed For ...

final getMixedPlaylistsProvider = Provider(
  (ref) => GetMixedPlaylists(ref.read(repositoryProvider)),
);

//discover with stations
final getStationsProvider = Provider(
  (ref) => GetStationPlaylists(ref.read(repositoryProvider)),
);

//more of what you like
final getMoreOfWhatYouLikeProvider = Provider(
  (ref) => GetMoreOfWhatYouLike(ref.read(repositoryProvider)),
);

//======UI providers======

//trending tracks
final trendingTracksProvider =
    FutureProvider.family<List<TrackSummary>, String>((ref, genre) {
      return ref.read(getTrendingTracksProvider).call(genre);
    });

///hot tracks
final hotTracksProvider = FutureProvider<List<TrackSummary>>((ref) {
  return ref.read(getHotTracksProvider).call();
});

//mixed playlists
final mixedPlaylistsProvider = FutureProvider((ref) {
  return ref.read(getMixedPlaylistsProvider).call();
});

//discover with stations
final discoverStationsProvider = FutureProvider((ref) {
  return ref.read(getStationsProvider).call();
});

//more of what you like
final moreOfWhatYouLikeProvider = FutureProvider((ref) {
  return ref.read(getMoreOfWhatYouLikeProvider).call();
});
