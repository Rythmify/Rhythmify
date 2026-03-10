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

  /// Fetches a list of tracks matching a search query.
  Future<List<TrackSummary>> searchTracks(String query);

  /// Fetches a list of tracks that contain a specific tag (e.g. "#lofi").
  Future<List<TrackSummary>> getTracksByTag(String tag);

  /// Fetches tracks uploaded by a specific artist (used on the Artist Profile screen).
  Future<List<TrackSummary>> getTracksByArtist(String artistId);

  //=========================
  //   --- Mutations ---
  //=========================

  /// Toggles the user's like status (liked or not).
  Future<void> toggleLike(String id, bool isCurrentlyLiked);

  /// Toggles the user's repost status (reposted or not).
  Future<void> toggleRepost(String id, bool isCurrentlyReposted);

  /// Tells the backend that the track was played (increments playCount).
  Future<void> recordPlay(String id);

  //=========================
  //  --- For Home Page ---
  //=========================

  /// Fetches trending tracks.
  Future<List<TrackSummary>> getTrendingTracks();

  /// Fetches trending tracks filtered by a specific genre.
  Future<List<TrackSummary>> getTrendingTracksByGenre(String genre);

  /// Fetches the single "Track of the Day".
  Future<TrackSummary> getHotTrackForYou();
  
}