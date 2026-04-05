import '../models/library_models.dart';

/// Abstract contract for all library remote data operations.
abstract class LibraryRemoteDatasource {
  Future<List<FollowedUserModel>> getFollowing({
    required int page,
    required int limit,
  });
  Future<void> unfollowUser({required String userId});

  Future<List<LibraryPlaylistModel>> getMyPlaylists();
  Future<LibraryPlaylistModel> createPlaylist({
    required String name,
    String? description,
    required bool isPublic,
  });
  Future<void> deletePlaylist({required String playlistId});

  Future<List<UploadedTrackModel>> getMyUploads({
    required int page,
    required int limit,
  });
  Future<void> toggleTrackVisibility({
    required String trackId,
    required bool isPublic,
  });
  Future<void> deleteTrack({required String trackId});

  Future<List<TrackInsightModel>> getMyInsights();

  Future<List<RecentlyPlayedEntryModel>> getRecentlyPlayed();
  Future<List<RecentlyPlayedEntryModel>> getListeningHistory({
    required int page,
    required int limit,
  });
  Future<void> clearListeningHistory();

  Future<List<LibraryStationModel>> getStations();

  Future<List<UploadedTrackModel>> getLikedTracks({
    required int page,
    required int limit,
  });
}
