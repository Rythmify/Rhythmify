import 'dart:io';

import 'package:dartz/dartz.dart';

import '../entities/collection_type.dart';
import '../entities/playlist_entity.dart';
import 'package:rythmify/core/error/failures.dart';
import '../entities/playlist_track.dart';
import '../entities/station_entity.dart';

/// Abstract contract for all playlist/album/station data operations.
///
/// Implemented by [UploadPlaylistRepositoryImpl] in the data layer.
/// Use cases depend only on this interface — never on the concrete impl.
///
/// Every method returns `Either<Failure, T>`:
/// - `Left(failure)` → something went wrong.
/// - `Right(value)`  → success.
abstract class PlaylistRepository {
  // ── Create / Update / Delete ──────────────────────────────────────────────

  /// Creates a new playlist or album via `POST /playlists`.
  ///
  /// [type] maps to the `subtype` field. Passing [CollectionType.station]
  /// here is a domain error — stations are read-only.
  Future<Either<Failure, PlaylistEntity>> createPlaylist({
    required String name,
    required bool isPublic,
    required CollectionType type,
  });

  /// Updates playlist metadata via `PATCH /playlists/{id}`.
  ///
  /// All parameters are optional — only non-null values are sent.
  /// Pass [removeCover] = true to clear the uploaded cover image.
  Future<Either<Failure, PlaylistEntity>> updatePlaylist({
    required String playlistId,
    String? name,
    String? description,
    bool? isPublic,
    File? coverImage,
    bool removeCover = false,
    String? subtype,
    String? releaseDate,
    String? genreId,
    List<String>? tags,
  });

  /// Permanently deletes a playlist via `DELETE /playlists/{id}`.
  Future<Either<Failure, void>> deletePlaylist(String playlistId);

  // ── Fetching ──────────────────────────────────────────────────────────────

  /// Fetches the authenticated user's playlists/albums via
  /// `GET /playlists?mine=true`.
  ///
  /// [filter] is `'created'` or `'liked'`.
  /// [albumView] = true returns only non-playlist subtypes.
  Future<Either<Failure, List<PlaylistEntity>>> fetchMyPlaylists({
    String filter = 'created',
    bool albumView = false,
    int limit = 20,
    int offset = 0,
  });

  /// Fetches a single playlist with its track list via
  /// `GET /playlists/{id}`.
  ///
  /// Pass [secretToken] to access private playlists as a non-owner.
  Future<Either<Failure, PlaylistEntity>> fetchPlaylistDetail({
    required String playlistId,
    String? secretToken,
  });

  /// Fetches paginated tracks for a playlist via
  /// `GET /playlists/{id}/tracks`.
  Future<Either<Failure, List<PlaylistTrack>>> fetchPlaylistTracks({
    required String playlistId,
    String? secretToken,
    int page = 1,
    int limit = 20,
  });

  // ── Track management ──────────────────────────────────────────────────────

  /// Adds a track to a playlist via `POST /playlists/{id}/tracks`.
  /// [position] is optional — omit to append to the end.
  Future<Either<Failure, void>> addTrackToPlaylist({
    required String playlistId,
    required String trackId,
    int? position,
  });

  /// Removes a track from a playlist via
  /// `DELETE /playlists/{id}/tracks/{trackId}`.
  Future<Either<Failure, void>> removeTrackFromPlaylist({
    required String playlistId,
    required String trackId,
  });

  /// Reorders tracks via `PATCH /playlists/{id}/tracks/reorder`.
  /// [orderedTrackIds] must be the complete current track list in the
  /// desired order — partial lists are rejected by the backend.
  Future<Either<Failure, void>> reorderPlaylistTracks({
    required String playlistId,
    required List<String> orderedTrackIds,
  });

  // ── Engagement ────────────────────────────────────────────────────────────

  /// Likes a playlist via `POST /playlists/{id}/like`.
  Future<Either<Failure, void>> likePlaylist(String playlistId);

  /// Unlikes a playlist via `DELETE /playlists/{id}/like`.
  Future<Either<Failure, void>> unlikePlaylist(String playlistId);

  /// Reposts a playlist via `POST /playlists/{id}/repost`.
  Future<Either<Failure, void>> repostPlaylist(String playlistId);

  /// Removes a repost via `DELETE /playlists/{id}/repost`.
  Future<Either<Failure, void>> removePlaylistRepost(String playlistId);

  // ── Stations ──────────────────────────────────────────────────────────────

  /// Fetches artist stations for the Home/Discovery screen via
  /// `GET /home/stations`.
  Future<Either<Failure, List<StationEntity>>> fetchStations({
    int limit = 10,
    int offset = 0,
  });

  /// Fetches tracks for a specific station via
  /// `GET /home/stations/{artistId}/tracks`.
  Future<Either<Failure, List<PlaylistTrack>>> fetchStationTracks({
    required String artistId,
    int limit = 50,
    int offset = 0,
  });
}
