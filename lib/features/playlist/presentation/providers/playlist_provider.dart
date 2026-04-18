// lib/features/playlist/presentation/providers/playlist_provider.dart
//
// Uses PlaylistRemoteDatasource directly for:
//   - Suggestions → fetchRecommendedTracks() (parallel artist track fetch)
//   - Station tracks → fetchStationTracks(artistId)
//
// This avoids GET /tracks which returns 404 on this backend.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/domain/entities/track.dart';
import '../../data/datasources/playlist_remote_datasource.dart';
import '../../data/mock/playlist_mock_data.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';

// ── Datasource provider ───────────────────────────────────────────────────────

final playlistDatasourceProvider = Provider<PlaylistRemoteDatasource>((ref) {
  return PlaylistRemoteDatasource(apiClient.dio);
});

// ════════════════════════════════════════════════════════════════════════════
// STATE CLASSES
// ════════════════════════════════════════════════════════════════════════════

class PlaylistListState {
  const PlaylistListState({
    this.playlists = const [],
    this.isLoading = false,
    this.error,
  });

  final List<PlaylistEntity> playlists;
  final bool isLoading;
  final String? error;

  PlaylistListState copyWith({
    List<PlaylistEntity>? playlists,
    bool? isLoading,
    String? error,
  }) =>
      PlaylistListState(
        playlists: playlists ?? this.playlists,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class PlaylistDetailState {
  const PlaylistDetailState({
    this.playlist,
    this.tracks = const [],
    this.suggestions = const [],
    this.isLoading = false,
    this.isLiked = false,
    this.error,
  });

  final PlaylistEntity? playlist;
  final List<PlaylistTrack> tracks;
  final List<PlaylistTrack> suggestions;
  final bool isLoading;
  final bool isLiked;
  final String? error;

  bool get showSuggestions =>
      suggestions.isNotEmpty && playlist?.type == PlaylistType.playlist;

  PlaylistDetailState copyWith({
    PlaylistEntity? playlist,
    List<PlaylistTrack>? tracks,
    List<PlaylistTrack>? suggestions,
    bool? isLoading,
    bool? isLiked,
    String? error,
  }) =>
      PlaylistDetailState(
        playlist: playlist ?? this.playlist,
        tracks: tracks ?? this.tracks,
        suggestions: suggestions ?? this.suggestions,
        isLoading: isLoading ?? this.isLoading,
        isLiked: isLiked ?? this.isLiked,
        error: error,
      );
}

// ════════════════════════════════════════════════════════════════════════════
// PLAYLIST LIST NOTIFIER
// ════════════════════════════════════════════════════════════════════════════

class PlaylistListNotifier extends Notifier<PlaylistListState> {
  @override
  PlaylistListState build() {
    final playlists = PlaylistMockData.instance.getMyPlaylists();
    return PlaylistListState(playlists: playlists);
  }

  final _db = PlaylistMockData.instance;

  void loadPlaylists() {
    state = state.copyWith(playlists: _db.getMyPlaylists());
  }

  PlaylistEntity createPlaylist({
    required String name,
    required bool isPublic,
  }) {
    final playlist = _db.create(name: name, isPublic: isPublic);
    loadPlaylists();
    return playlist;
  }

  void updatePlaylist({
    required String playlistId,
    required String name,
    required bool isPublic,
    String? description,
  }) {
    _db.update(
      playlistId: playlistId,
      name: name,
      isPublic: isPublic,
      description: description,
    );
    loadPlaylists();
  }

  void updateCoverImage({
    required String playlistId,
    required String localPath,
  }) {
    _db.updateCoverImage(playlistId: playlistId, localPath: localPath);
    loadPlaylists();
  }

  void deletePlaylist(String playlistId) {
    _db.delete(playlistId);
    loadPlaylists();
  }

  PlaylistEntity createStation(PlaylistTrack seedTrack) {
    final station = _db.createStation(seedTrack: seedTrack);
    loadPlaylists();
    return station;
  }

  PlaylistEntity createStationFromTrack(Track seedTrack) {
    final pt = PlaylistTrack.fromTrack(seedTrack);
    final station = _db.createStation(seedTrack: pt);
    loadPlaylists();
    return station;
  }

  PlaylistEntity convertToAlbum(String playlistId) {
    final updated = _db.convertToAlbum(playlistId);
    loadPlaylists();
    return updated;
  }

  PlaylistEntity convertToStation(String playlistId) {
    final updated = _db.convertToStation(playlistId);
    loadPlaylists();
    return updated;
  }

  PlaylistEntity convertToPlaylist(String playlistId) {
    final updated = _db.convertToPlaylist(playlistId);
    loadPlaylists();
    return updated;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PLAYLIST DETAIL NOTIFIER
// ════════════════════════════════════════════════════════════════════════════

class PlaylistDetailNotifier extends Notifier<PlaylistDetailState> {
  final _db = PlaylistMockData.instance;
  String? _currentPlaylistId;

  PlaylistRemoteDatasource get _datasource =>
      ref.read(playlistDatasourceProvider);

  @override
  PlaylistDetailState build() => const PlaylistDetailState(isLoading: true);

  /// Called from PlaylistDetailScreen.initState.
  Future<void> init(String playlistId) async {
    _currentPlaylistId = playlistId;
    state = const PlaylistDetailState(isLoading: true);

    final playlist = _db.getById(playlistId);
    if (playlist == null) {
      state = const PlaylistDetailState(error: 'Playlist not found');
      return;
    }

    // ── Stations: load real tracks from backend ──────────────────────────
    if (playlist.type == PlaylistType.station &&
        playlist.seedArtistName != null) {
      final stationTracks = await _fetchStationTracks(playlist.seedArtistName!);
      state = PlaylistDetailState(
        playlist: playlist,
        tracks: stationTracks,
        suggestions: const [],
        isLoading: false,
      );
      return;
    }

    // ── Playlists and albums: mock tracks + real suggestions ─────────────
    final mockTracks = _db.getTracksFor(playlistId);
    final suggestions = await _fetchSuggestions(mockTracks);

    state = PlaylistDetailState(
      playlist: playlist,
      tracks: mockTracks,
      suggestions: suggestions,
      isLoading: false,
    );
  }

  /// Fetches real recommended tracks using fetchRecommendedTracks()
  /// which hits GET /users/{artistId}/tracks in parallel.
  /// Filters out tracks already in the playlist.
  Future<List<PlaylistTrack>> _fetchSuggestions(
    List<PlaylistTrack> existingTracks,
  ) async {
    try {
      final existingIds = existingTracks.map((t) => t.id).toSet();
      final recommended = await _datasource.fetchRecommendedTracks(limit: 15);
      final filtered = recommended
          .where((t) => !existingIds.contains(t.id))
          .take(10)
          .toList()
        ..shuffle();
      // ignore: avoid_print
      print('[PlaylistDetailNotifier] Loaded ${filtered.length} suggestions');
      return filtered;
    } catch (e) {
      // ignore: avoid_print
      print('[PlaylistDetailNotifier] Could not load suggestions: $e');
      return [];
    }
  }

  /// Fetches tracks for a station from GET /home/stations/{artistId}/tracks.
  Future<List<PlaylistTrack>> _fetchStationTracks(String artistId) async {
    try {
      final tracks = await _datasource.fetchStationTracks(artistId, limit: 50);
      // ignore: avoid_print
      print('[PlaylistDetailNotifier] Loaded ${tracks.length} station tracks');
      return tracks;
    } catch (e) {
      // ignore: avoid_print
      print('[PlaylistDetailNotifier] Could not load station tracks: $e');
      return [];
    }
  }

  /// Re-fetches fresh suggestions. Called by "Refresh suggestions" button.
  Future<void> refreshSuggestions() async {
    final fresh = await _fetchSuggestions(state.tracks);
    state = state.copyWith(suggestions: fresh);
  }

  void addSuggestion(PlaylistTrack track) {
    if (_currentPlaylistId == null) return;
    _db.addTrack(playlistId: _currentPlaylistId!, track: track);
    final updatedSuggestions =
        state.suggestions.where((s) => s.id != track.id).toList();
    state = state.copyWith(
      playlist: _db.getById(_currentPlaylistId!),
      tracks: _db.getTracksFor(_currentPlaylistId!),
      suggestions: updatedSuggestions,
    );
  }

  void removeTrack(String trackId) {
    if (_currentPlaylistId == null) return;
    _db.removeTrack(playlistId: _currentPlaylistId!, trackId: trackId);
    state = state.copyWith(
      playlist: _db.getById(_currentPlaylistId!),
      tracks: _db.getTracksFor(_currentPlaylistId!),
    );
  }

  void toggleLike() {
    state = state.copyWith(isLiked: !state.isLiked);
  }

  void reload() {
    if (_currentPlaylistId != null) {
      init(_currentPlaylistId!);
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ════════════════════════════════════════════════════════════════════════════

final playlistListProvider =
    NotifierProvider<PlaylistListNotifier, PlaylistListState>(
  PlaylistListNotifier.new,
);

final playlistDetailProvider =
    NotifierProvider<PlaylistDetailNotifier, PlaylistDetailState>(
  PlaylistDetailNotifier.new,
);