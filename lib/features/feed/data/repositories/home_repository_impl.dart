import '../datasources/home_datasource.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';
import '../../../../core/domain/entities/track.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDatasource datasource;

  HomeRepositoryImpl(this.datasource);

  @override
  Future<HomeData> getHomeData() => datasource.getHomeData();

  @override
  Future<GenreTabTracks> getTrendingByGenre(String genreId) =>
      datasource.getTrendingByGenre(genreId);

  @override
  Future<HotForYou> getHotForYou() => datasource.getHotForYou();

  @override
  Future<List<Track>> getMoreOfWhatYouLike() =>
      datasource.getMoreOfWhatYouLike();

  @override
  Future<List<MixedForYouItem>> getMixedForYou() => datasource.getMixedForYou();

  @override
  Future<List<DiscoverStation>> getDiscoverStations() =>
      datasource.getDiscoverStations();
}
