import '../../../../core/domain/entities/track.dart';

abstract class HomeRepository {
  Future<List<Track>> getTrendingTracks(String genre);
  Future<List<Track>> getHotTracks();
  Future<List<Map<String, dynamic>>> getMixedPlaylists();
  Future<List<Map<String, dynamic>>> getStationPlaylists();
  Future<List<Map<String, dynamic>>> getMoreOfWhatYouLikePlaylists();
}
