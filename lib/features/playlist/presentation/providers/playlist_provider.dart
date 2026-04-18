// lib/features/playlist/presentation/providers/playlist_provider.dart

import 'package:dio/dio.dart';
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
    this.isSuggestionsLoading = false,
    this.isLiked = false,
    this.error,
  });

  final PlaylistEntity? playlist;
  final List<PlaylistTrack> tracks;
  final List<PlaylistTrack> suggestions;
  final bool isLoading;
  final bool isSuggestionsLoading;
  final bool isLiked;
  final String? error;

  bool get showSuggestions =>
      suggestions.isNotEmpty && playlist?.type == PlaylistType.playlist;

  PlaylistDetailState copyWith({
    PlaylistEntity? playlist,
    List<PlaylistTrack>? tracks,
    List<PlaylistTrack>? suggestions,
    bool? isLoading,
    bool? isSuggestionsLoading,
    bool? isLiked,
    String? error,
  }) =>
      PlaylistDetailState(
        playlist: playlist ?? this.playlist,
        tracks: tracks ?? this.tracks,
        suggestions: suggestions ?? this.suggestions,
        isLoading: isLoading ?? this.isLoading,
        isSuggestionsLoading: isSuggestionsLoading ?? this.isSuggestionsLoading,
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

  PlaylistRemoteDatasource get _datasource =>
      ref.read(playlistDatasourceProvider);

  void loadPlaylists() {
    state = state.copyWith(playlists: _db.getMyPlaylists());
  }

  // ── CREATE: real backend → store real UUID in mock ────────────────────────
  // Async — sheet must await and check for null before navigating.
  Future<PlaylistEntity?> createPlaylist({
    required String name,
    required bool isPublic,
  }) async {
    try {
      final created = await _datasource.createPlaylist(
        name: name,
        isPublic: isPublic,
      );

      // Store with the real UUID so all subsequent API calls use a valid UUID
      _db.createWithId(
        id: created.id,
        name: created.name,
        isPublic: created.isPublic,
        ownerName: created.ownerName,
        ownerId: created.ownerId,
      );

      loadPlaylists();
      print('[LIST] ✅ Created playlist "${created.name}" id=${created.id}');
      return created;
    } catch (e) {
      print('[LIST] ❌ createPlaylist failed: $e');
      return null;
    }
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

  Future<void> init(String playlistId) async {
    _currentPlaylistId = playlistId;
    state = const PlaylistDetailState(isLoading: true);

    final playlist = _db.getById(playlistId);
    if (playlist == null) {
      state = const PlaylistDetailState(error: 'Playlist not found');
      return;
    }

    // ── Stations ──────────────────────────────────────────────────────────
    if (playlist.type == PlaylistType.station &&
        playlist.seedArtistName != null) {
      final stationTracks =
          await _fetchStationTracks(playlist.seedArtistName!);
      state = PlaylistDetailState(
        playlist: playlist,
        tracks: stationTracks,
        suggestions: const [],
        isLoading: false,
      );
      return;
    }

    // ── Playlists/Albums: show screen immediately, load suggestions in bg ──
    final mockTracks = _db.getTracksFor(playlistId);
    state = PlaylistDetailState(
      playlist: playlist,
      tracks: mockTracks,
      suggestions: const [],
      isLoading: false,
      isSuggestionsLoading: playlist.type == PlaylistType.playlist,
    );

    if (playlist.type == PlaylistType.playlist) {
      final suggestions = await _fetchSuggestionsExcluding(mockTracks);
      state = state.copyWith(
        suggestions: suggestions,
        isSuggestionsLoading: false,
      );
    }
  }

  // ── Add suggestion ────────────────────────────────────────────────────────
  Future<void> addSuggestion(PlaylistTrack suggestion) async {
    if (_currentPlaylistId == null) return;

    // Optimistic removal for instant UI feedback
    final optimisticSuggestions =
        state.suggestions.where((s) => s.id != suggestion.id).toList();
    state = state.copyWith(suggestions: optimisticSuggestions);

    try {
      await _datasource.addTrackToPlaylist(
        playlistId: _currentPlaylistId!,
        trackId: suggestion.id,
      );

      print('[DETAIL] ✅ "${suggestion.title}" added to backend');

      // Mirror in mock store so track list updates immediately
      _db.addTrack(playlistId: _currentPlaylistId!, track: suggestion);
      final updatedTracks = _db.getTracksFor(_currentPlaylistId!);

      // Fresh suggestions excluding everything now in the playlist
      final freshSuggestions =
          await _fetchSuggestionsExcluding(updatedTracks);

      state = state.copyWith(
        playlist: _db.getById(_currentPlaylistId!),
        tracks: updatedTracks,
        suggestions: freshSuggestions,
      );
    } on DioException catch (e) {
      print('[DETAIL] ❌ addSuggestion ${e.response?.statusCode}: ${e.response?.data}');
      state = state.copyWith(
        suggestions: [...optimisticSuggestions, suggestion],
        error: 'Could not add "${suggestion.title}". Try again.',
      );
    } catch (e) {
      print('[DETAIL] ❌ addSuggestion unexpected: $e');
      state = state.copyWith(
        suggestions: [...optimisticSuggestions, suggestion],
      );
    }
  }

  // ── Refresh suggestions ───────────────────────────────────────────────────
  Future<void> refreshSuggestions() async {
    state = state.copyWith(isSuggestionsLoading: true);
    final fresh = await _fetchSuggestionsExcluding(state.tracks);
    state = state.copyWith(
      suggestions: fresh,
      isSuggestionsLoading: false,
    );
    print('[DETAIL] refresh: ${fresh.length} suggestions');
  }

  void removeTrack(String trackId) {
    if (_currentPlaylistId == null) return;
    _db.removeTrack(playlistId: _currentPlaylistId!, trackId: trackId);
    state = state.copyWith(
      playlist: _db.getById(_currentPlaylistId!),
      tracks: _db.getTracksFor(_currentPlaylistId!),
    );
  }

  void toggleLike() => state = state.copyWith(isLiked: !state.isLiked);

  void reload() {
    if (_currentPlaylistId != null) init(_currentPlaylistId!);
  }

  Future<List<PlaylistTrack>> _fetchSuggestionsExcluding(
    List<PlaylistTrack> existing,
  ) async {
    try {
      return await _datasource.fetchRecommendedTracksExcluding(
        excludeIds: existing.map((t) => t.id).toList(),
        limit: 5,
      );
    } catch (e) {
      print('[DETAIL] _fetchSuggestionsExcluding failed: $e');
      return [];
    }
  }

  Future<List<PlaylistTrack>> _fetchStationTracks(String artistId) async {
    try {
      return await _datasource.fetchStationTracks(artistId, limit: 50);
    } catch (e) {
      print('[DETAIL] _fetchStationTracks failed: $e');
      return [];
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