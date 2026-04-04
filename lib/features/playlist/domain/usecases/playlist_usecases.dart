import 'dart:io';

import 'package:dartz/dartz.dart';

import '../entities/playlist_entity.dart';
import 'package:rythmify/core/error/failures.dart';
import '../entities/playlist_track_item.dart';
import '../entities/station_entity.dart';
import '../repositories/playlist_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// FetchMyPlaylistsUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Fetches the authenticated user's own playlists or liked playlists.
///
/// [filter] is `'created'` (default) or `'liked'`.
/// [albumView] = true returns album/EP/single/compilation subtypes only.
class FetchMyPlaylistsUseCase {
  const FetchMyPlaylistsUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, List<PlaylistEntity>>> call({
    String filter = 'created',
    bool albumView = false,
    int limit = 20,
    int offset = 0,
  }) {
    return _repository.fetchMyPlaylists(
      filter: filter,
      albumView: albumView,
      limit: limit,
      offset: offset,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FetchPlaylistDetailUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Fetches a single playlist entity including its track list.
///
/// Pass [secretToken] to access private playlists as a non-owner.
class FetchPlaylistDetailUseCase {
  const FetchPlaylistDetailUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, PlaylistEntity>> call({
    required String playlistId,
    String? secretToken,
  }) {
    return _repository.fetchPlaylistDetail(
      playlistId: playlistId,
      secretToken: secretToken,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FetchPlaylistTracksUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Fetches paginated tracks for a playlist.
///
/// Used by [PlaylistDetailScreen] to load the track list lazily after
/// the header is already displayed.
class FetchPlaylistTracksUseCase {
  const FetchPlaylistTracksUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, List<PlaylistTrackItem>>> call({
    required String playlistId,
    String? secretToken,
    int page = 1,
    int limit = 20,
  }) {
    return _repository.fetchPlaylistTracks(
      playlistId: playlistId,
      secretToken: secretToken,
      page: page,
      limit: limit,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// UpdatePlaylistUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Updates playlist metadata. All parameters are optional — only non-null
/// values are sent. The backend will reject a request with no changes (422).
///
/// The use case enforces: if [name] is provided it cannot be empty.
class UpdatePlaylistUseCase {
  const UpdatePlaylistUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, PlaylistEntity>> call({
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
  }) {
    if (name != null && name.trim().isEmpty) {
      return Future.value(
        const Left(PlaylistValidationFailure('Playlist name cannot be empty.')),
      );
    }
    return _repository.updatePlaylist(
      playlistId: playlistId,
      name: name?.trim(),
      description: description,
      isPublic: isPublic,
      coverImage: coverImage,
      removeCover: removeCover,
      subtype: subtype,
      releaseDate: releaseDate,
      genreId: genreId,
      tags: tags,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DeletePlaylistUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Permanently deletes a playlist.
///
/// There is no soft-delete — once called, the playlist and all its
/// playlist_track entries are gone. The UI must confirm before calling.
class DeletePlaylistUseCase {
  const DeletePlaylistUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, void>> call(String playlistId) {
    return _repository.deletePlaylist(playlistId);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AddTrackToPlaylistUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Adds a track to a playlist.
///
/// [position] is 1-based. Omit to append to the end.
/// The backend rejects duplicate tracks (409) and invalid positions (422).
class AddTrackToPlaylistUseCase {
  const AddTrackToPlaylistUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, void>> call({
    required String playlistId,
    required String trackId,
    int? position,
  }) {
    return _repository.addTrackToPlaylist(
      playlistId: playlistId,
      trackId: trackId,
      position: position,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RemoveTrackFromPlaylistUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Removes a track from a playlist by track ID.
///
/// The backend re-normalises positions after removal (no gaps).
class RemoveTrackFromPlaylistUseCase {
  const RemoveTrackFromPlaylistUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, void>> call({
    required String playlistId,
    required String trackId,
  }) {
    return _repository.removeTrackFromPlaylist(
      playlistId: playlistId,
      trackId: trackId,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ReorderPlaylistTracksUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Reorders all tracks in a playlist.
///
/// [orderedTrackIds] must be the COMPLETE current list of track IDs in the
/// desired order (no subsets — the backend requires a full list).
///
/// Domain validation: list cannot be empty.
class ReorderPlaylistTracksUseCase {
  const ReorderPlaylistTracksUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, void>> call({
    required String playlistId,
    required List<String> orderedTrackIds,
  }) {
    if (orderedTrackIds.isEmpty) {
      return Future.value(
        const Left(PlaylistValidationFailure('Track list cannot be empty.')),
      );
    }
    return _repository.reorderPlaylistTracks(
      playlistId: playlistId,
      orderedTrackIds: orderedTrackIds,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TogglePlaylistLikeUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Likes or unlikes a playlist in one use case.
///
/// Pass [liked] = true to like, false to unlike.
/// The UI passes the current like state so the use case picks the right call.
class TogglePlaylistLikeUseCase {
  const TogglePlaylistLikeUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, void>> call({
    required String playlistId,
    required bool liked,
  }) {
    return liked
        ? _repository.unlikePlaylist(playlistId)
        : _repository.likePlaylist(playlistId);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TogglePlaylistRepostUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Reposts or removes a repost of a playlist in one use case.
class TogglePlaylistRepostUseCase {
  const TogglePlaylistRepostUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, void>> call({
    required String playlistId,
    required bool reposted,
  }) {
    return reposted
        ? _repository.removePlaylistRepost(playlistId)
        : _repository.repostPlaylist(playlistId);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FetchStationsUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Fetches artist stations for the Home/Discovery screen.
class FetchStationsUseCase {
  const FetchStationsUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, List<StationEntity>>> call({
    int limit = 10,
    int offset = 0,
  }) {
    return _repository.fetchStations(limit: limit, offset: offset);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FetchStationTracksUseCase
// ═══════════════════════════════════════════════════════════════════════════

/// Fetches tracks for an artist station via `/home/stations/{artistId}/tracks`.
class FetchStationTracksUseCase {
  const FetchStationTracksUseCase(this._repository);
  final PlaylistRepository _repository;

  Future<Either<Failure, List<PlaylistTrackItem>>> call({
    required String artistId,
    int limit = 50,
    int offset = 0,
  }) {
    return _repository.fetchStationTracks(
      artistId: artistId,
      limit: limit,
      offset: offset,
    );
  }
}