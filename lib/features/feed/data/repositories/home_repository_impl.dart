import '../../../feed/domain/repositories/home_repository.dart';
import '../../../../core/domain/entities/track_summary.dart';
import '../datasources/home_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDatasource datasource;

  HomeRepositoryImpl(this.datasource);

  @override
  Future<List<TrackSummary>> getTrendingTracks(String genre) {
    return datasource.getTrendingTracks(genre);
  }

  @override
  Future<List<TrackSummary>> getHotTracks() {
    return datasource.getHotTracks();
  }

  @override
  Future<List<Map<String, dynamic>>> getMixedPlaylists() {
    return datasource.getMixedPlaylists();
  }
}
