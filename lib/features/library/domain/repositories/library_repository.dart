import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/library_entities.dart';

/// Contract for all Library data operations.
///
/// Covers: Following, Playlists, Uploads, Insights, History, Stations.
/// All methods return [Either] — [Left] wraps [Failure], [Right] wraps the result.
abstract class LibraryRepository {
  // ── Following ──────────────────────────────────────────────────────────────

  /// Fetch the list of users the authenticated user follows.
  Future<Either<Failure, List<FollowedUser>>> getFollowing({
    required int page,
    required int limit,
  });

  /// Unfollow a user by [userId].
  Future<Either<Failure, void>> unfollowUser({required String userId});

  // ── Playlists ──────────────────────────────────────────────────────────────

  /// Fetch all playlists owned or saved by the authenticated user.
  Future<Either<Failure, List<LibraryPlaylist>>> getMyPlaylists();

  /// Create a new playlist.
  Future<Either<Failure, LibraryPlaylist>> createPlaylist({
    required String name,
    String? description,
    required bool isPublic,
  });

  /// Delete a playlist owned by the authenticated user.
  Future<Either<Failure, void>> deletePlaylist({required String playlistId});

  // ── Uploads ────────────────────────────────────────────────────────────────

  /// Fetch tracks uploaded by the authenticated user.
  Future<Either<Failure, List<UploadedTrack>>> getMyUploads({
    required int page,
    required int limit,
  });

  /// Toggle the public/private visibility of an uploaded track.
  Future<Either<Failure, void>> toggleTrackVisibility({
    required String trackId,
    required bool isPublic,
  });

  /// Permanently delete an uploaded track.
  Future<Either<Failure, void>> deleteTrack({required String trackId});

  // ── Insights ───────────────────────────────────────────────────────────────

  /// Fetch analytics summary for the authenticated user's uploaded tracks.
  Future<Either<Failure, List<TrackInsight>>> getMyInsights();

  // ── History ────────────────────────────────────────────────────────────────

  /// Fetch deduplicated recently played tracks (max 20).
  Future<Either<Failure, List<RecentlyPlayedEntry>>> getRecentlyPlayed();

  /// Fetch full paginated listening history.
  Future<Either<Failure, List<RecentlyPlayedEntry>>> getListeningHistory({
    required int page,
    required int limit,
  });

  /// Clear all listening history.
  Future<Either<Failure, void>> clearListeningHistory();

  // ── Stations ───────────────────────────────────────────────────────────────

  /// Fetch artist stations (based on followed artists).
  Future<Either<Failure, List<LibraryStation>>> getStations();

  // ── Liked tracks ──────────────────────────────────────────────────────────

  /// Fetch paginated liked tracks for the authenticated user.
  Future<Either<Failure, List<LikedTrack>>> getLikedTracks({
    required int page,
    required int limit,
  });
}
