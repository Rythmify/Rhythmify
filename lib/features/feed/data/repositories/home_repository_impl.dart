import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';
import '../../../../core/domain/entities/track.dart';
import '../datasources/home_mock_datasource.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource? _remote;
  final HomeMockDatasource? _mock;

  HomeRepositoryImpl.remote(HomeRemoteDatasource remote)
    : _remote = remote,
      _mock = null;

  HomeRepositoryImpl.mock(HomeMockDatasource mock)
    : _mock = mock,
      _remote = null;

  @override
  Future<HomeData> getHomeData() =>
      _mock?.getHomeData() ?? _remote!.getHomeData();

  @override
  Future<GenreTabTracks> getTrendingByGenre(String genreId) =>
      _mock?.getTrendingByGenre(genreId) ??
      _remote!.getTrendingByGenre(genreId);

  @override
  Future<HotForYou> getHotForYou() =>
      _mock?.getHotForYou() ?? _remote!.getHotForYou();

  @override
  Future<List<Track>> getMoreOfWhatYouLike() =>
      _mock?.getMoreOfWhatYouLike() ?? _remote!.getMoreOfWhatYouLike();

  @override
  Future<List<MixedForYouItem>> getMixedForYou() =>
      _mock?.getMixedForYou() ?? _remote!.getMixedForYou();

  @override
  Future<List<DiscoverStation>> getDiscoverStations() =>
      _mock?.getDiscoverStations() ?? _remote!.getDiscoverStations();

  @override
  Future<List<Track>> getMixTracks(String mixId) =>
      _remote!.getMixTracks(mixId);

  @override
  Future<List<Track>> getRelatedTracks(String trackId) =>
      _remote!.getRelatedTracks(trackId);
}
