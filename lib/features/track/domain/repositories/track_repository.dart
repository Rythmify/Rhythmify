import '../../../../core/domain/entities/track.dart';

abstract class TrackRepository {
  //=========================
  //   --- Fetching Data ---
  //=========================

  /// Fetches track data (including waveformData and description if available)
  Future<Track> getTrackDetails(String id);

  /// Fetches all tracks
  Future<List<Track>> getTracks();

  /// Fetches waveform peaks for a specific track
  Future<List<double>> getWaveform(String trackId);

  /// Fetches all tags (mapped as ID to Name)
  Future<Map<String, String>> getTags();

  //=========================
  //   --- Mutations ---
  //=========================

  /// Toggles the user's like status (liked or not).
  Future<void> toggleLike(String id, bool isCurrentlyLiked);

  /// Toggles the user's repost status (reposted or not).
  Future<void> toggleRepost(String id, bool isCurrentlyReposted);

  /// Tells the backend that the track was played (increments playCount).
  Future<void> recordPlay(String id);
}
