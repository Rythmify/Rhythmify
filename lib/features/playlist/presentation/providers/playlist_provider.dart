// ============================================================
// PLAYLIST PROVIDER — Riverpod 3.x compatible
// ============================================================
// Your project has riverpod_generator ^4.0.3 which means
// flutter_riverpod 3.x. In v3:
//   - FamilyNotifier is REMOVED
//   - For family-style providers, the cleanest approach without
//     the code generator is to store the ID inside the notifier
//     constructor and create a cached provider per ID.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/playlist_mock_data.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';

// ════════════════════════════════════════════════════════════
// STATE CLASSES
// ════════════════════════════════════════════════════════════

/// State for the Library playlists list screen.
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

/// State for the playlist detail screen.
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

  bool get showSuggestions => suggestions.isNotEmpty;

  PlaylistDetailState copyWith({
    PlaylistEntity? playlist,
    List<PlaylistTrack>? tracks,
    List<PlaylistTrack>? suggestions,
    bool? isLoading,
    String? error,
  }) =>
      PlaylistDetailState(
        playlist: playlist ?? this.playlist,
        tracks: tracks ?? this.tracks,
        suggestions: suggestions ?? this.suggestions,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ════════════════════════════════════════════════════════════
// NOTIFIERS
// ════════════════════════════════════════════════════════════

/// Manages the list of playlists shown in Library.
class PlaylistListNotifier extends Notifier<PlaylistListState> {
  @override
  PlaylistListState build() {
    // Load playlists immediately when first created.
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

  void deletePlaylist(String playlistId) {
    _db.delete(playlistId);
    loadPlaylists();
  }

  PlaylistEntity createStation(PlaylistTrack seedTrack) {
    final station = _db.createStation(seedTrack: seedTrack);
    loadPlaylists();
    return station;
  }
}

/// Manages one playlist's detail page.
///
/// Riverpod 3.x dropped FamilyNotifier. The workaround is to pass
/// the playlist ID through the constructor, then use the cached
/// provider function [playlistDetailProvider] below instead of
/// a .family provider.
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
    final updatedSuggestions =
        state.suggestions.where((s) => s.id != track.id).toList();
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

// ════════════════════════════════════════════════════════════
// PROVIDERS
// ════════════════════════════════════════════════════════════

/// The list of playlists. Used by Library playlists screen.
///
/// Usage in a widget:
///   final state = ref.watch(playlistListProvider);
///   ref.read(playlistListProvider.notifier).createPlaylist(...);
final playlistListProvider =
    NotifierProvider<PlaylistListNotifier, PlaylistListState>(
  PlaylistListNotifier.new,
);

/// Cache so the same playlist ID always gets the same provider instance.
/// Without this, watching the same ID twice would create two notifiers.
final _detailProviderCache =
    <String, NotifierProvider<PlaylistDetailNotifier, PlaylistDetailState>>{};

/// Returns the detail provider for a given playlist ID.
///
/// Usage in a widget:
///   final state = ref.watch(playlistDetailProvider('pl-001'));
///   ref.read(playlistDetailProvider('pl-001').notifier).addSuggestion(track);
NotifierProvider<PlaylistDetailNotifier, PlaylistDetailState>
    playlistDetailProvider(String playlistId) {
  return _detailProviderCache.putIfAbsent(
    playlistId,
    () => NotifierProvider<PlaylistDetailNotifier, PlaylistDetailState>(
      () => PlaylistDetailNotifier(playlistId),
    ),
  );
}