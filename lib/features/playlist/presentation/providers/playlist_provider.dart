// lib/features/playlist/presentation/providers/playlist_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/playlist_mock_data.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';

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
  }) => PlaylistListState(
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
    this.error,
  });

  final PlaylistEntity? playlist;
  final List<PlaylistTrack> tracks;
  final List<PlaylistTrack> suggestions;
  final bool isLoading;
  final String? error;

  // Suggestions only show for playlists, not albums or stations
  bool get showSuggestions =>
      suggestions.isNotEmpty && playlist?.type == PlaylistType.playlist;

  PlaylistDetailState copyWith({
    PlaylistEntity? playlist,
    List<PlaylistTrack>? tracks,
    List<PlaylistTrack>? suggestions,
    bool? isLoading,
    String? error,
  }) => PlaylistDetailState(
    playlist: playlist ?? this.playlist,
    tracks: tracks ?? this.tracks,
    suggestions: suggestions ?? this.suggestions,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

// ════════════════════════════════════════════════════════════════════════════
// NOTIFIERS
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

  // ── Convert operations ─────────────────────────────────────────────────────

  /// Converts a playlist → album. After converting, navigate to albums section.
  PlaylistEntity convertToAlbum(String playlistId) {
    final updated = _db.convertToAlbum(playlistId);
    loadPlaylists();
    return updated;
  }

  /// Converts a playlist → station. After converting, navigate to stations section.
  PlaylistEntity convertToStation(String playlistId) {
    final updated = _db.convertToStation(playlistId);
    loadPlaylists();
    return updated;
  }

  /// Converts album/station → playlist.
  PlaylistEntity convertToPlaylist(String playlistId) {
    final updated = _db.convertToPlaylist(playlistId);
    loadPlaylists();
    return updated;
  }
}

class PlaylistDetailNotifier extends Notifier<PlaylistDetailState> {
  PlaylistDetailNotifier(this._playlistId);

  final String _playlistId;
  final _db = PlaylistMockData.instance;

  @override
  PlaylistDetailState build() => _buildState();

  PlaylistDetailState _buildState() {
    final playlist = _db.getById(_playlistId);
    if (playlist == null) {
      return const PlaylistDetailState(error: 'Playlist not found');
    }
    return PlaylistDetailState(
      playlist: playlist,
      tracks: _db.getTracksFor(_playlistId),
      suggestions: _db.getSuggestions(),
    );
  }

  void addSuggestion(PlaylistTrack track) {
    _db.addTrack(playlistId: _playlistId, track: track);
    final updatedSuggestions = state.suggestions
        .where((s) => s.id != track.id)
        .toList();
    state = state.copyWith(
      playlist: _db.getById(_playlistId),
      tracks: _db.getTracksFor(_playlistId),
      suggestions: updatedSuggestions,
    );
  }

  void removeTrack(String trackId) {
    _db.removeTrack(playlistId: _playlistId, trackId: trackId);
    state = state.copyWith(
      playlist: _db.getById(_playlistId),
      tracks: _db.getTracksFor(_playlistId),
    );
  }

  void refreshSuggestions() {
    state = state.copyWith(suggestions: _db.getSuggestions());
  }

  void reload() {
    state = _buildState();
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ════════════════════════════════════════════════════════════════════════════

final playlistListProvider =
    NotifierProvider<PlaylistListNotifier, PlaylistListState>(
      PlaylistListNotifier.new,
    );

final _detailProviderCache =
    <String, NotifierProvider<PlaylistDetailNotifier, PlaylistDetailState>>{};

NotifierProvider<PlaylistDetailNotifier, PlaylistDetailState>
playlistDetailProvider(String playlistId) {
  return _detailProviderCache.putIfAbsent(
    playlistId,
    () => NotifierProvider<PlaylistDetailNotifier, PlaylistDetailState>(
      () => PlaylistDetailNotifier(playlistId),
    ),
  );
}
