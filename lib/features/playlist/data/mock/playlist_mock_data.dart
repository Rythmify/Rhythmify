// lib/features/playlist/data/mock/playlist_mock_data.dart
//
// In-memory store that now accepts real backend UUIDs via createWithId.
// All NEW playlists go through createWithId (real UUID from backend).
// The legacy create() method is kept for anything that doesn't need backend.

import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';

class PlaylistMockData {
  PlaylistMockData._();
  static final PlaylistMockData instance = PlaylistMockData._();

  final List<PlaylistEntity> _playlists = [];
  final Map<String, List<PlaylistTrack>> _playlistTracks = {};

  // ── READ ──────────────────────────────────────────────────────────────────

  List<PlaylistEntity> getMyPlaylists() => List.from(_playlists);

  List<PlaylistEntity> getAlbums() =>
      _playlists.where((p) => p.type == PlaylistType.album).toList();

  List<PlaylistEntity> getStations() =>
      _playlists.where((p) => p.type == PlaylistType.station).toList();

  List<PlaylistTrack> getTracksFor(String playlistId) =>
      List.from(_playlistTracks[playlistId] ?? []);

  PlaylistEntity? getById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── CREATE with real backend UUID ─────────────────────────────────────────
  // Call this after createPlaylist() returns from the backend.
  // The id here is the real UUID the backend assigned.
  PlaylistEntity createWithId({
    required String id,
    required String name,
    required bool isPublic,
    String ownerName = 'Me',
    String ownerId = '',
  }) {
    // Don't duplicate if already exists (e.g. called twice)
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
    _playlistTracks[id] = [];
    print('[MockDB] Registered real playlist: $name  id=$id');
    return playlist;
  }

  // ── Legacy create (mock ID) — kept for non-backend flows ─────────────────
  PlaylistEntity create({required String name, required bool isPublic}) {
    final newPlaylist = PlaylistEntity(
      id: 'pl-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      ownerName: 'Me',
      ownerId: 'user-001',
      isPublic: isPublic,
      type: PlaylistType.playlist,
      trackCount: 0,
      totalDuration: Duration.zero,
      coverUrl: null,
      createdAt: DateTime.now(),
    );
    _playlists.insert(0, newPlaylist);
    _playlistTracks[newPlaylist.id] = [];
    print('[MockDB] Created mock playlist: ${newPlaylist.name}');
    return newPlaylist;
  }

  void update({
    required String playlistId,
    required String name,
    required bool isPublic,
    String? description,
  }) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    _playlists[index] = _playlists[index].copyWith(
      name: name,
      isPublic: isPublic,
      description: description,
    );
    print('[MockDB] Updated playlist $playlistId → name=$name');
  }

  void updateCoverImage({
    required String playlistId,
    required String localPath,
  }) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    _playlists[index] = _playlists[index].copyWith(coverUrl: localPath);
    print('[MockDB] Updated cover for $playlistId');
  }

  void delete(String playlistId) {
    _playlists.removeWhere((p) => p.id == playlistId);
    _playlistTracks.remove(playlistId);
    print('[MockDB] Deleted playlist $playlistId');
  }

  void addTrack({required String playlistId, required PlaylistTrack track}) {
    final tracks = _playlistTracks[playlistId] ?? [];
    if (tracks.any((t) => t.id == track.id)) return;
    tracks.add(track.copyWith(position: tracks.length + 1));
    _playlistTracks[playlistId] = tracks;
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        trackCount: tracks.length,
        totalDuration: _recalcDuration(tracks),
      );
    }
    print('[MockDB] Added track ${track.title} to $playlistId');
  }

  void removeTrack({required String playlistId, required String trackId}) {
    final tracks = _playlistTracks[playlistId] ?? [];
    tracks.removeWhere((t) => t.id == trackId);
    for (int i = 0; i < tracks.length; i++) {
      tracks[i] = tracks[i].copyWith(position: i + 1);
    }
    _playlistTracks[playlistId] = tracks;
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(
        trackCount: tracks.length,
        totalDuration: _recalcDuration(tracks),
      );
    }
  }

  Duration _recalcDuration(List<PlaylistTrack> tracks) =>
      tracks.fold(Duration.zero, (sum, t) => sum + t.duration);

  // ── CONVERT ───────────────────────────────────────────────────────────────

  PlaylistEntity convertToAlbum(String playlistId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return _playlists.first;
    final updated = _playlists[index].copyWith(
      type: PlaylistType.album,
      releaseYear: DateTime.now().year.toString(),
    );
    _playlists[index] = updated;
    print('[MockDB] Converted $playlistId to album');
    return updated;
  }

  PlaylistEntity convertToStation(String playlistId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return _playlists.first;
    final updated = _playlists[index].copyWith(
      type: PlaylistType.station,
      seedArtistName: _playlists[index].ownerName,
    );
    _playlists[index] = updated;
    print('[MockDB] Converted $playlistId to station');
    return updated;
  }

  PlaylistEntity convertToPlaylist(String playlistId) {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return _playlists.first;
    final updated = _playlists[index].copyWith(type: PlaylistType.playlist);
    _playlists[index] = updated;
    print('[MockDB] Converted $playlistId to playlist');
    return updated;
  }

  // ── STATION CREATION ──────────────────────────────────────────────────────

  PlaylistEntity createStation({required PlaylistTrack seedTrack}) {
    final station = PlaylistEntity(
      id: 'st-${DateTime.now().millisecondsSinceEpoch}',
      name: '${seedTrack.artistName} Radio',
      ownerName: 'Me',
      ownerId: 'user-001',
      isPublic: false,
      type: PlaylistType.station,
      trackCount: 0,
      totalDuration: Duration.zero,
      coverUrl: seedTrack.coverUrl,
      createdAt: DateTime.now(),
      seedArtistName: seedTrack.artistName,
    );
    _playlists.insert(0, station);
    _playlistTracks[station.id] = [];
    print('[MockDB] Created station: ${station.name}');
    return station;
  }
}