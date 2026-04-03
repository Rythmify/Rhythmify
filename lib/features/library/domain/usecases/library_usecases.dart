import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/track.dart';
import '../entities/library_entities.dart';
import '../repositories/library_repository.dart';

// ────────────────────────────────────────────────
// Following
// ────────────────────────────────────────────────

/// Fetches the paginated list of users the current user follows.
class GetFollowingUseCase {
  final LibraryRepository repository;
  GetFollowingUseCase(this.repository);

  Future<Either<Failure, List<FollowedUser>>> call({
    int page = 1,
    int limit = 20,
  }) =>
      repository.getFollowing(page: page, limit: limit);
}

/// Unfollows a user.
class UnfollowUserLibraryUseCase {
  final LibraryRepository repository;
  UnfollowUserLibraryUseCase(this.repository);

  Future<Either<Failure, void>> call({required String userId}) =>
      repository.unfollowUser(userId: userId);
}

// ────────────────────────────────────────────────
// Playlists
// ────────────────────────────────────────────────

/// Fetches all playlists owned or saved by the current user.
class GetMyPlaylistsUseCase {
  final LibraryRepository repository;
  GetMyPlaylistsUseCase(this.repository);

  Future<Either<Failure, List<LibraryPlaylist>>> call() =>
      repository.getMyPlaylists();
}

/// Creates a new playlist.
class CreatePlaylistUseCase {
  final LibraryRepository repository;
  CreatePlaylistUseCase(this.repository);

  Future<Either<Failure, LibraryPlaylist>> call({
    required String name,
    String? description,
    required bool isPublic,
  }) =>
      repository.createPlaylist(
        name: name,
        description: description,
        isPublic: isPublic,
      );
}

/// Deletes a playlist owned by the current user.
class DeletePlaylistUseCase {
  final LibraryRepository repository;
  DeletePlaylistUseCase(this.repository);

  Future<Either<Failure, void>> call({required String playlistId}) =>
      repository.deletePlaylist(playlistId: playlistId);
}

// ────────────────────────────────────────────────
// Uploads
// ────────────────────────────────────────────────

/// Fetches the current user's uploaded tracks.
class GetMyUploadsUseCase {
  final LibraryRepository repository;
  GetMyUploadsUseCase(this.repository);

  Future<Either<Failure, List<UploadedTrack>>> call({
    int page = 1,
    int limit = 20,
  }) =>
      repository.getMyUploads(page: page, limit: limit);
}

/// Toggles a track's public/private visibility.
class ToggleTrackVisibilityUseCase {
  final LibraryRepository repository;
  ToggleTrackVisibilityUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String trackId,
    required bool isPublic,
  }) =>
      repository.toggleTrackVisibility(trackId: trackId, isPublic: isPublic);
}

/// Permanently deletes an uploaded track.
class DeleteTrackUseCase {
  final LibraryRepository repository;
  DeleteTrackUseCase(this.repository);

  Future<Either<Failure, void>> call({required String trackId}) =>
      repository.deleteTrack(trackId: trackId);
}

// ────────────────────────────────────────────────
// Insights
// ────────────────────────────────────────────────

/// Fetches analytics for the current user's tracks.
class GetMyInsightsUseCase {
  final LibraryRepository repository;
  GetMyInsightsUseCase(this.repository);

  Future<Either<Failure, List<TrackInsight>>> call() =>
      repository.getMyInsights();
}

// ────────────────────────────────────────────────
// History
// ────────────────────────────────────────────────

/// Fetches the deduplicated recently played list (max 20).
class GetRecentlyPlayedUseCase {
  final LibraryRepository repository;
  GetRecentlyPlayedUseCase(this.repository);

  Future<Either<Failure, List<RecentlyPlayedEntry>>> call() =>
      repository.getRecentlyPlayed();
}

/// Fetches the full paginated listening history.
class GetListeningHistoryUseCase {
  final LibraryRepository repository;
  GetListeningHistoryUseCase(this.repository);

  Future<Either<Failure, List<RecentlyPlayedEntry>>> call({
    int page = 1,
    int limit = 20,
  }) =>
      repository.getListeningHistory(page: page, limit: limit);
}

/// Clears all listening history.
class ClearListeningHistoryUseCase {
  final LibraryRepository repository;
  ClearListeningHistoryUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.clearListeningHistory();
}

// ────────────────────────────────────────────────
// Stations
// ────────────────────────────────────────────────

/// Fetches artist stations seeded from followed artists.
class GetStationsUseCase {
  final LibraryRepository repository;
  GetStationsUseCase(this.repository);

  Future<Either<Failure, List<LibraryStation>>> call() =>
      repository.getStations();
}

// ────────────────────────────────────────────────
// Liked Tracks
// ────────────────────────────────────────────────

/// Fetches the paginated liked tracks list.
class GetLikedTracksLibraryUseCase {
  final LibraryRepository repository;
  GetLikedTracksLibraryUseCase(this.repository);

  Future<Either<Failure, List<Track>>> call({
    int page = 1,
    int limit = 20,
  }) =>
      repository.getLikedTracks(page: page, limit: limit);
}
