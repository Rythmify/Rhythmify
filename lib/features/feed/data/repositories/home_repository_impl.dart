import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';
import '../../../../core/domain/entities/track.dart';
import '../datasources/home_mock_datasource.dart';
import '../datasources/home_remote_datasource.dart';

/// Concrete implementation of [HomeRepository] that supports both
/// remote and mock data sources.
///
/// Use [HomeRepositoryImpl.remote] in production and
/// [HomeRepositoryImpl.mock] during development or testing.
/// Each method prefers the mock datasource when available,
/// falling back to the remote datasource otherwise.
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource? _remote;
  final HomeMockDatasource? _mock;

  /// Creates a [HomeRepositoryImpl] backed by a live [HomeRemoteDatasource].
  HomeRepositoryImpl.remote(HomeRemoteDatasource remote)
    : _remote = remote,
      _mock = null;

  /// Creates a [HomeRepositoryImpl] backed by a [HomeMockDatasource].
  ///
  /// Useful for UI development and testing without a live backend.
  HomeRepositoryImpl.mock(HomeMockDatasource mock)
    : _mock = mock,
      _remote = null;

  /// Fetches the full home screen data, preferring mock over remote.
  @override
  Future<HomeData> getHomeData() =>
      _mock?.getHomeData() ?? _remote!.getHomeData();

  /// Fetches trending tracks for the given [genreId], preferring mock over remote.
  @override
  Future<GenreTabTracks> getTrendingByGenre(String genreId) =>
      _mock?.getTrendingByGenre(genreId) ??
      _remote!.getTrendingByGenre(genreId);

  /// Fetches the "Hot For You" section, preferring mock over remote.
  @override
  Future<HotForYou> getHotForYou() =>
      _mock?.getHotForYou() ?? _remote!.getHotForYou();

  /// Fetches the "More Of What You Like" track list, preferring mock over remote.
  @override
  Future<List<Track>> getMoreOfWhatYouLike() =>
      _mock?.getMoreOfWhatYouLike() ?? _remote!.getMoreOfWhatYouLike();

  /// Fetches the "Mixed For You" item list, preferring mock over remote.
  @override
  Future<List<MixedForYouItem>> getMixedForYou() =>
      _mock?.getMixedForYou() ?? _remote!.getMixedForYou();

  /// Fetches the list of discover stations, preferring mock over remote.
  @override
  Future<List<DiscoverStation>> getDiscoverStations() =>
      _mock?.getDiscoverStations() ?? _remote!.getDiscoverStations();

  /// Fetches the tracks belonging to a specific mix by [mixId].
  ///
  /// Always uses the remote datasource — mock does not support this endpoint.
  @override
  Future<List<Track>> getMixTracks(String mixId) =>
      _remote!.getMixTracks(mixId);

  /// Fetches tracks related to a specific track by [trackId].
  ///
  /// Always uses the remote datasource — mock does not support this endpoint.
  @override
  Future<List<Track>> getRelatedTracks(String trackId) =>
      _remote!.getRelatedTracks(trackId);
}
