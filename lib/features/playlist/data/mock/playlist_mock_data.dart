// lib/features/playlist/data/mock/playlist_mock_data.dart
//
// This is now a LOCAL IN-MEMORY CACHE, not the source of truth.
// The backend is the source of truth. This cache exists so:
//   1. The UI doesn't re-fetch on every rebuild
//   2. The edit sheet can read playlist metadata without an extra call
//   3. Optimistic UI updates work before the backend confirms

import 'package:flutter/foundation.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';

class PlaylistMockData {
  PlaylistMockData._();
  static final PlaylistMockData instance = PlaylistMockData._();

  // Starts empty — populated by syncFromBackend() when the list screen loads
  final List<PlaylistEntity> _playlists = [];
  final Map<String, List<PlaylistTrack>> _tracks = {};

  // ── READ ──────────────────────────────────────────────────────────────────

  List<PlaylistEntity> getMyPlaylists() => List.from(_playlists);

  List<PlaylistEntity> getAlbums() =>
      _playlists.where((p) => p.type == PlaylistType.album).toList();

  List<PlaylistEntity> getStations() =>
      _playlists.where((p) => p.type == PlaylistType.station).toList();

  List<PlaylistTrack> getTracksFor(String playlistId) =>
      List.from(_tracks[playlistId] ?? []);

  PlaylistEntity? getById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── SYNC FROM BACKEND ─────────────────────────────────────────────────────
  // Called after fetchMyPlaylists() returns. Replaces the entire list
  // with what the backend says, preserving locally-added track entries.
  void syncFromBackend(List<PlaylistEntity> backendPlaylists) {
    // Keep track entries for playlists that are still in the list
    final keepIds = backendPlaylists.map((p) => p.id).toSet();
    _tracks.removeWhere((id, _) => !keepIds.contains(id));

    _playlists
      ..clear()
      ..addAll(backendPlaylists);

    debugPrint(
      '[Cache] Synced ${backendPlaylists.length} playlists from backend',
    );
  }

  // ── CREATE WITH REAL ID ───────────────────────────────────────────────────
  // Called after POST /playlists succeeds. Stores the real UUID so
  // all subsequent API calls use it instead of a fake "pl-..." ID.
  PlaylistEntity createWithId({
    required String id,
    required String name,
    required bool isPublic,
    String ownerName = 'Me',
    String ownerId = '',
  }) {
    if (_playlists.any((p) => p.id == id)) {
      return _playlists.firstWhere((p) => p.id == id);
    }
    final playlist = PlaylistEntity(
      id: id,
      name: name,
      ownerName: ownerName,
      ownerId: ownerId,
      isPublic: isPublic,
      type: PlaylistType.playlist,
      trackCount: 0,
      totalDuration: Duration.zero,
      coverUrl: null,
      createdAt: DateTime.now(),
    );
    _playlists.insert(0, playlist);
    _tracks[id] = [];
    return playlist;
  }

  // ── CLEAR TRACKS ─────────────────────────────────────────────────────────
  // Called before re-syncing tracks from backend to avoid duplicates.
  void clearTracks(String playlistId) {
    _tracks[playlistId] = [];
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  void update({
    required String playlistId,
    required String name,
    required bool isPublic,
    String? description,
  }) {
    final i = _playlists.indexWhere((p) => p.id == playlistId);
    if (i == -1) return;
    _playlists[i] = _playlists[i].copyWith(
      name: name,
      isPublic: isPublic,
      description: description,
    );
  }

  void updateCoverImage({
    required String playlistId,
    required String localPath,
  }) {
    final i = _playlists.indexWhere((p) => p.id == playlistId);
    if (i == -1) return;
    _playlists[i] = _playlists[i].copyWith(coverUrl: localPath);
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  void delete(String playlistId) {
    _playlists.removeWhere((p) => p.id == playlistId);
    _tracks.remove(playlistId);
  }

  // ── TRACKS ────────────────────────────────────────────────────────────────
  void addTrack({required String playlistId, required PlaylistTrack track}) {
    final list = _tracks[playlistId] ?? [];
    if (list.any((t) => t.id == track.id)) return;
    list.add(track.copyWith(position: list.length + 1));
    _tracks[playlistId] = list;
    _updateTrackCount(playlistId);
  }

  void removeTrack({required String playlistId, required String trackId}) {
    final list = _tracks[playlistId] ?? [];
    list.removeWhere((t) => t.id == trackId);
    for (int i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(position: i + 1);
    }
    _tracks[playlistId] = list;
    _updateTrackCount(playlistId);
  }

  void _updateTrackCount(String playlistId) {
    final i = _playlists.indexWhere((p) => p.id == playlistId);
    if (i == -1) return;
    final list = _tracks[playlistId] ?? [];
    Duration total = Duration.zero;
    for (final t in list) {
      total += t.duration;
    }
    _playlists[i] = _playlists[i].copyWith(
      trackCount: list.length,
      totalDuration: total,
    );
  }

  // ── CONVERT ───────────────────────────────────────────────────────────────
  PlaylistEntity convertToAlbum(String playlistId) {
    final i = _playlists.indexWhere((p) => p.id == playlistId);
    if (i == -1) return _playlists.first;
    final updated = _playlists[i].copyWith(
      type: PlaylistType.album,
      releaseYear: DateTime.now().year.toString(),
    );
    _playlists[i] = updated;
    return updated;
  }

  // ============================================================
  // REPLACE convertToStation in PlaylistMockData
  // inside playlist_mock_data.dart
  //
  // Now accepts optional seedArtistName so the station tile
  // shows "Based on [name]" correctly.
  // ============================================================

  PlaylistEntity convertToStation(String playlistId, {String? seedArtistName}) {
    final i = _playlists.indexWhere((p) => p.id == playlistId);
    if (i == -1) return _playlists.first;
    final updated = _playlists[i].copyWith(
      type: PlaylistType.station,
      seedArtistName: seedArtistName ?? _playlists[i].ownerName,
    );
    _playlists[i] = updated;
    return updated;
  }

  PlaylistEntity convertToPlaylist(String playlistId) {
    final i = _playlists.indexWhere((p) => p.id == playlistId);
    if (i == -1) return _playlists.first;
    final updated = _playlists[i].copyWith(type: PlaylistType.playlist);
    _playlists[i] = updated;
    return updated;
  }

  // ── STATION ───────────────────────────────────────────────────────────────
  PlaylistEntity createStation({required PlaylistTrack seedTrack}) {
    final station = PlaylistEntity(
      id: 'st-${DateTime.now().millisecondsSinceEpoch}',
      name: '${seedTrack.artistName} Radio',
      ownerName: 'Me',
      ownerId: '',
      isPublic: false,
      type: PlaylistType.station,
      trackCount: 0,
      totalDuration: Duration.zero,
      coverUrl: seedTrack.coverUrl,
      createdAt: DateTime.now(),
      seedArtistName: seedTrack.artistName,
    );
    _playlists.insert(0, station);
    _tracks[station.id] = [];
    return station;
  }
}
