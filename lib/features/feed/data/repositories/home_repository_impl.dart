import '../../../feed/domain/repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';
import '../datasources/home_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDatasource datasource;

  HomeRepositoryImpl(this.datasource);

  @override
  Future<List<Track>> getTrendingTracks(String genre) {
    return datasource.getTrendingTracks(genre);
  }

  @override
  Future<List<Track>> getHotTracks() {
    return datasource.getHotTracks();
  }

  @override
  Future<List<Map<String, dynamic>>> getMixedPlaylists() {
    return datasource.getMixedPlaylists();
  }

  @override
  Future<List<Map<String, dynamic>>> getStationPlaylists() {
    return datasource.getStationPlaylists();
  }

  @override
  Future<List<Map<String, dynamic>>> getMoreOfWhatYouLikePlaylists() {
    return datasource.getMoreOfWhatYouLikePlaylists();
  }
}
