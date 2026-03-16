import '../../../../core/domain/entities/track_summary.dart';

abstract class HomeRepository {
  Future<List<TrackSummary>> getTrendingTracks(String genre);

  Future<List<TrackSummary>> getHotTracks();

  Future<List<Map<String, dynamic>>> getMixedPlaylists();
}
