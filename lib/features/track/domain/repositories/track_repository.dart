import '../../../../core/domain/entities/track.dart';
import '../../../../core/domain/entities/track_summary.dart';

abstract class TrackRepository {

  //=========================
  //   --- Fetching Data ---
  //=========================

  /// Fetches FULL details (including waveformData and description)
  Future<Track> getTrackDetails(String id);

  /// Fetches basic metadata ONLY (used for quick previews of track e.g. in home page)
  Future<TrackSummary> getTrackSummary(String id);

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