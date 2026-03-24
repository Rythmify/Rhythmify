import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_more__you_like.dart';
import '../../data/datasources/home_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/usecases/get_trending_tracks.dart';
import '../../domain/usecases/get_hot_tracks.dart';
import '../../domain/usecases/get_mixed_playlists.dart';
import '../../domain/usecases/get_discover_stations.dart';
import '../../../../core/domain/entities/track.dart';

/// Provides an instance of [HomeDatasource].
///
/// This is the **lowest layer in the Home feature data flow** and is responsible
/// for fetching raw data (e.g., API calls, local assets, or mock data).
///
/// Output:
/// - Returns a [HomeDatasource] instance
final datasourceProvider = Provider((ref) => HomeDatasource());

/// Provides an implementation of [HomeRepositoryImpl].
///
/// This repository acts as an abstraction layer between:
/// - Data sources (raw data)
/// - Domain use cases (business logic)
///
/// Input:
/// - Depends on [datasourceProvider]
///
/// Output:
/// - Returns a [HomeRepositoryImpl] instance
final repositoryProvider = Provider(
  (ref) => HomeRepositoryImpl(ref.read(datasourceProvider)),
);

/// ====== Use Case Providers ======

/// Use case provider for fetching trending tracks.
///
/// This encapsulates business logic for retrieving trending music
/// based on a specific genre.
///
/// Input:
/// - [genre]: String representing the music genre filter
///
/// Output:
/// - Returns a [GetTrendingTracks] use case instance
final getTrendingTracksProvider = Provider(
  (ref) => GetTrendingTracks(ref.read(repositoryProvider)),
);

/// Use case provider for fetching "Hot For You" tracks.
///
/// This represents personalized or algorithm-driven track recommendations.
///
/// Output:
/// - Returns a [GetHotTracks] use case instance
final getHotTracksProvider = Provider(
  (ref) => GetHotTracks(ref.read(repositoryProvider)),
);

/// Use case provider for fetching mixed playlist recommendations.
///
/// This provides curated playlists combining different music styles.
///
/// Output:
/// - Returns a [GetMixedPlaylists] use case instance
final getMixedPlaylistsProvider = Provider(
  (ref) => GetMixedPlaylists(ref.read(repositoryProvider)),
);

/// Use case provider for fetching discovery stations.
///
/// This provides radio-like or station-based music discovery content.
///
/// Output:
/// - Returns a [GetStationPlaylists] use case instance
final getStationsProvider = Provider(
  (ref) => GetStationPlaylists(ref.read(repositoryProvider)),
);

/// Use case provider for fetching "More of What You Like" recommendations.
///
/// This provides additional personalized recommendations based on user behavior.
///
/// Output:
/// - Returns a [GetMoreOfWhatYouLike] use case instance
final getMoreOfWhatYouLikeProvider = Provider(
  (ref) => GetMoreOfWhatYouLike(ref.read(repositoryProvider)),
);

/// ====== UI State Providers ======

/// Provides a list of trending tracks filtered by genre.
///
/// This is consumed by the UI layer to display trending music sections.
///
/// Input:
/// - [genre]: The selected music genre
///
/// Output:
/// - A [Future] containing a list of [Track] entities
final trendingTracksProvider = FutureProvider.family<List<Track>, String>((
  ref,
  genre,
) {
  return ref.read(getTrendingTracksProvider).call(genre);
});

/// Provides "Hot For You" personalized tracks.
///
/// Used by the UI to render personalized recommendations.
///
/// Output:
/// - A [Future] containing a list of [Track] entities
final hotTracksProvider = FutureProvider<List<Track>>((ref) {
  return ref.read(getHotTracksProvider).call();
});

/// Provides mixed playlist recommendations for the home feed.
///
/// Output:
/// - A [Future] containing playlist/track data
final mixedPlaylistsProvider = FutureProvider((ref) {
  return ref.read(getMixedPlaylistsProvider).call();
});

/// Provides discovery stations for the home feed.
///
/// Output:
/// - A [Future] containing station-based recommendations
final discoverStationsProvider = FutureProvider((ref) {
  return ref.read(getStationsProvider).call();
});

/// Provides personalized "More of What You Like" recommendations.
///
/// Output:
/// - A [Future] containing a list of recommended tracks
final moreOfWhatYouLikeProvider = FutureProvider((ref) {
  return ref.read(getMoreOfWhatYouLikeProvider).call();
});
