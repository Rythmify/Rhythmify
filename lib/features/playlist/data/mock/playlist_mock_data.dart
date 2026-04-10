// lib/features/playlist/data/mock/playlist_mock_data.dart
/// In-memory store for all playlist data during the mock phase.
/// Tracks are seeded automatically from [allTracksProvider] via [playlistMockSeederProvider]
/// so any uploaded track appears in playlists without manual wiring.
/// Each method maps 1-to-1 to a backend endpoint — replace with a repository impl to go live.
/// [getSourceTracksFor] returns full [Track] entities for the player; [getTracksFor] returns UI rows.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/entities/track.dart';
import '../../../track/presentation/providers/track_provider.dart'; // allTracksProvider
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';

class PlaylistMockData {
  PlaylistMockData._();
  static final instance = PlaylistMockData._();

  final List<PlaylistEntity> _playlists = [
    PlaylistEntity(
      id: 'pl-001',
      name: 'My Playlist',
      ownerName: 'You',
      ownerId: 'user-me',
      type: PlaylistType.playlist,
      isPublic: true,
      isLiked: false,
      trackCount: 0,
      totalDuration: Duration.zero,
      createdAt: DateTime(2024, 1, 1), // ← fixed
    ),
    PlaylistEntity(
      id: 'pl-002',
      name: 'Uploaded Tracks',
      ownerName: 'You',
      ownerId: 'user-me',
      type: PlaylistType.playlist,
      isPublic: true,
      isLiked: false,
      trackCount: 0,
      totalDuration: Duration.zero,
      createdAt: DateTime(2024, 1, 1), // ← fixed
    ),
  ];

  // playlistId → List<Track> (source Track entities for the player)
  final Map<String, List<Track>> _sourceTracks = {'pl-001': [], 'pl-002': []};

  // Static suggestions — replace with personalised API later
  final List<PlaylistTrack> _suggestions = [];

  // ── Seeding ────────────────────────────────────────────────────────────────

  void seedFromRealTracks(List<Track> tracks) {
    for (final id in _sourceTracks.keys) {
      _sourceTracks[id] = List<Track>.from(tracks);
    }
    // Rebuild suggestions from the first 5 tracks
    _suggestions
      ..clear()
      ..addAll(
        tracks.take(5).map((t) => PlaylistTrack.fromTrack(t, position: 0)),
      );
    debugPrint('[PlaylistMockData] seeded ${tracks.length} tracks');
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  List<PlaylistEntity> getMyPlaylists() => List.unmodifiable(_playlists);

  PlaylistEntity? getById(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<PlaylistTrack> getTracksFor(String playlistId) {
    final tracks = _sourceTracks[playlistId] ?? [];
    return tracks
        .asMap()
        .entries
        .map((e) => PlaylistTrack.fromTrack(e.value, position: e.key + 1))
        .toList();
  }

  List<Track> getSourceTracksFor(String playlistId) {
    return List<Track>.from(_sourceTracks[playlistId] ?? []);
  }

  List<PlaylistTrack> getSuggestions() => List.unmodifiable(_suggestions);

  // ── Mutations ─────────────────────────────────────────────────────────────

  PlaylistEntity create({required String name, required bool isPublic}) {
    final newPlaylist = PlaylistEntity(
      id: 'pl-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      ownerName: 'You',
      ownerId: 'user-me',
      type: PlaylistType.playlist,
      isPublic: isPublic,
      isLiked: false,
      trackCount: 0,
      totalDuration: Duration.zero,
      createdAt: DateTime.now(), // ← fixed
    );
    _playlists.add(newPlaylist);
    _sourceTracks[newPlaylist.id] = [];
    debugPrint('[PlaylistMockData] created: ${newPlaylist.id}');
    return newPlaylist;
  }

  // Matches what the provider calls: update(playlistId, name, isPublic, description)
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
    debugPrint('[PlaylistMockData] updated: $playlistId');
  }

  void delete(String id) {
    _playlists.removeWhere((p) => p.id == id);
    _sourceTracks.remove(id);
    debugPrint('[PlaylistMockData] deleted: $id');
  }

  // Matches what the provider calls: updateCoverImage(playlistId, localPath)
  void updateCoverImage({
    required String playlistId,
    required String localPath,
  }) {
    final i = _playlists.indexWhere((p) => p.id == playlistId);
    if (i == -1) return;
    _playlists[i] = _playlists[i].copyWith(coverUrl: localPath);
    debugPrint('[PlaylistMockData] coverImage updated: $playlistId');
  }

  void addTrack({required String playlistId, required Track track}) {
    _sourceTracks.putIfAbsent(playlistId, () => []);
    final already = _sourceTracks[playlistId]!.any((t) => t.id == track.id);
    if (!already) {
      _sourceTracks[playlistId]!.add(track);
      debugPrint('[PlaylistMockData] addTrack: ${track.id} → $playlistId');
    }
  }

  void removeTrack({required String playlistId, required String trackId}) {
    _sourceTracks[playlistId]?.removeWhere((t) => t.id == trackId);
    debugPrint('[PlaylistMockData] removeTrack: $trackId from $playlistId');
  }

  // ── Convert operations ─────────────────────────────────────────────────────

  PlaylistEntity convertToAlbum(String playlistId) {
    final i = _playlists.indexWhere((p) => p.id == playlistId);
    if (i == -1) throw StateError('Playlist not found: $playlistId');
    _playlists[i] = _playlists[i].copyWith(
      type: PlaylistType.album,
      releaseYear: DateTime.now().year.toString(),
    );
    debugPrint('[PlaylistMockData] convertToAlbum: $playlistId');
    return _playlists[i];
  }

  PlaylistEntity convertToStation(String playlistId) {
    final i = _playlists.indexWhere((p) => p.id == playlistId);
    if (i == -1) throw StateError('Playlist not found: $playlistId');
    _playlists[i] = _playlists[i].copyWith(type: PlaylistType.station);
    debugPrint('[PlaylistMockData] convertToStation: $playlistId');
    return _playlists[i];
  }

  PlaylistEntity convertToPlaylist(String playlistId) {
    final i = _playlists.indexWhere((p) => p.id == playlistId);
    if (i == -1) throw StateError('Playlist not found: $playlistId');
    _playlists[i] = _playlists[i].copyWith(type: PlaylistType.playlist);
    debugPrint('[PlaylistMockData] convertToPlaylist: $playlistId');
    return _playlists[i];
  }

  PlaylistEntity createStation({required PlaylistTrack seedTrack}) {
    final station = PlaylistEntity(
      id: 'st-${DateTime.now().millisecondsSinceEpoch}',
      name: '${seedTrack.artistName} Station',
      ownerName: 'You',
      ownerId: 'user-me',
      type: PlaylistType.station,
      isPublic: false,
      isLiked: false,
      trackCount: 0,
      totalDuration: Duration.zero,
      createdAt: DateTime.now(),
      seedTrackTitle: seedTrack.title,
      seedArtistName: seedTrack.artistName,
    );
    _playlists.add(station);
    _sourceTracks[station.id] = [];
    debugPrint('[PlaylistMockData] createStation: ${station.id}');
    return station;
  }
}

// ─── Seeder provider ──────────────────────────────────────────────────────────

final playlistMockSeederProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<List<Track>>>(allTracksProvider, (_, next) {
    next.whenData((tracks) {
      PlaylistMockData.instance.seedFromRealTracks(tracks);
    });
  });
});
