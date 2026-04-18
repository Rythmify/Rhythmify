// lib/features/playlist/presentation/providers/playlist_provider.dart
//
// Fully backend-integrated. MockData is used only as a local
// in-memory cache. Every write hits the real backend FIRST,
// then updates the cache on success.

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
        isSuggestionsLoading:
            isSuggestionsLoading ?? this.isSuggestionsLoading,
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
    // Start empty — loadPlaylists() called from screen's initState
    return const PlaylistListState(isLoading: true);
  }

  final _cache = PlaylistMockData.instance;
  PlaylistRemoteDatasource get _ds => ref.read(playlistDatasourceProvider);

  // ── LOAD ──────────────────────────────────────────────────────────────────
  Future<void> loadPlaylists() async {
    state = state.copyWith(isLoading: true);
    try {
      final playlists = await _ds.fetchMyPlaylists(filter: 'created');
      _cache.syncFromBackend(playlists);
      state = PlaylistListState(playlists: playlists);
      print('[LIST] ✅ Loaded ${playlists.length} playlists');
    } on DioException catch (e) {
      print('[LIST] ❌ loadPlaylists ${e.response?.statusCode}');
      state = PlaylistListState(
        playlists: _cache.getMyPlaylists(),
        error: 'Could not refresh playlists',
      );
    }
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<PlaylistEntity?> createPlaylist({
    required String name,
    required bool isPublic,
  }) async {
    try {
      final created = await _ds.createPlaylist(name: name, isPublic: isPublic);
      _cache.createWithId(
        id: created.id,
        name: created.name,
        isPublic: created.isPublic,
        ownerName: created.ownerName,
        ownerId: created.ownerId,
      );
      await loadPlaylists();
      print('[LIST] ✅ Created "${created.name}" id=${created.id}');
      return created;
    } catch (e) {
      print('[LIST] ❌ createPlaylist: $e');
      return null;
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<void> updatePlaylist({
    required String playlistId,
    required String name,
    required bool isPublic,
    String? description,
  }) async {
    try {
      await _ds.updatePlaylist(
        playlistId: playlistId,
        name: name,
        isPublic: isPublic,
        description: description,
      );
      _cache.update(
        playlistId: playlistId,
        name: name,
        isPublic: isPublic,
        description: description,
      );
      await loadPlaylists();
      print('[LIST] ✅ Updated $playlistId');
    } catch (e) {
      print('[LIST] ❌ updatePlaylist: $e');
    }
  }

  // ── UPDATE COVER ──────────────────────────────────────────────────────────
  // Cover is uploaded via updatePlaylist(coverImage: file) in the datasource.
  // This method just keeps the local display path in sync.
  void updateCoverImage({
    required String playlistId,
    required String localPath,
  }) {
    _cache.updateCoverImage(playlistId: playlistId, localPath: localPath);
    state = state.copyWith(playlists: _cache.getMyPlaylists());
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _ds.deletePlaylist(playlistId);
      _cache.delete(playlistId);
      await loadPlaylists();
      print('[LIST] ✅ Deleted $playlistId');
    } catch (e) {
      print('[LIST] ❌ deletePlaylist: $e');
    }
  }

  // ── CONVERT (local cache only — backend subtype PATCH wired separately) ───
// ── CONVERT TO ALBUM ──────────────────────────────────────────────────────
  // Calls PATCH /playlists/{id} with subtype=album on the backend.
  // On success updates local cache and reloads the list.
  Future<void> convertToAlbum(String playlistId) async {
    try {
      await _ds.updatePlaylist(
        playlistId: playlistId,
        subtype: 'album',
        releaseDate: '${DateTime.now().year}-01-01',
      );
      _cache.convertToAlbum(playlistId);
      await loadPlaylists();
      print('[LIST] ✅ Converted $playlistId to album');
    } catch (e) {
      print('[LIST] ❌ convertToAlbum: $e');
    }
  }
 
  // ── CONVERT TO PLAYLIST ───────────────────────────────────────────────────
  // Calls PATCH /playlists/{id} with subtype=playlist on the backend.
  Future<void> convertToPlaylist(String playlistId) async {
    try {
      await _ds.updatePlaylist(
        playlistId: playlistId,
        subtype: 'playlist',
      );
      _cache.convertToPlaylist(playlistId);
      await loadPlaylists();
      print('[LIST] ✅ Converted $playlistId back to playlist');
    } catch (e) {
      print('[LIST] ❌ convertToPlaylist: $e');
    }
  }
 
  // ── CONVERT TO STATION (local only for now) ───────────────────────────────
  PlaylistEntity convertToStation(String playlistId) {
    final updated = _cache.convertToStation(playlistId);
    state = state.copyWith(playlists: _cache.getMyPlaylists());
    return updated;
  }

  // ── STATION ───────────────────────────────────────────────────────────────
  PlaylistEntity createStation(PlaylistTrack seedTrack) {
    final station = _cache.createStation(seedTrack: seedTrack);
    state = state.copyWith(playlists: _cache.getMyPlaylists());
    return station;
  }

  PlaylistEntity createStationFromTrack(Track seedTrack) {
    final pt = PlaylistTrack.fromTrack(seedTrack);
    final station = _cache.createStation(seedTrack: pt);
    state = state.copyWith(playlists: _cache.getMyPlaylists());
    return station;
  }
}

// ════════════════════════════════════════════════════════════════════════════
// PLAYLIST DETAIL NOTIFIER
// ════════════════════════════════════════════════════════════════════════════

class PlaylistDetailNotifier extends Notifier<PlaylistDetailState> {
  final _cache = PlaylistMockData.instance;
  String? _currentPlaylistId;

  PlaylistRemoteDatasource get _ds => ref.read(playlistDatasourceProvider);

  @override
  PlaylistDetailState build() => const PlaylistDetailState(isLoading: true);

  // ── INIT ──────────────────────────────────────────────────────────────────
  Future<void> init(String playlistId) async {
    _currentPlaylistId = playlistId;
    state = const PlaylistDetailState(isLoading: true);

    try {
      // Fetch playlist detail and tracks in parallel
      final results = await Future.wait([
        _ds.fetchPlaylistDetail(playlistId),
        _ds.fetchPlaylistTracks(playlistId),
      ]);

      final playlist = results[0] as PlaylistEntity;
      final tracks = results[1] as List<PlaylistTrack>;

      // Keep cache in sync
      _cache.createWithId(
        id: playlist.id,
        name: playlist.name,
        isPublic: playlist.isPublic,
        ownerName: playlist.ownerName,
        ownerId: playlist.ownerId,
      );
      _cache.clearTracks(playlistId);
      for (final t in tracks) {
        _cache.addTrack(playlistId: playlistId, track: t);
      }

      print('[DETAIL] ✅ "${playlist.name}" — ${tracks.length} tracks');

      // ── Station: fetch station tracks instead ──────────────────────────
      if (playlist.type == PlaylistType.station &&
          playlist.seedArtistName != null) {
        final stationTracks =
            await _fetchStationTracks(playlist.seedArtistName!);
        state = PlaylistDetailState(
          playlist: playlist,
          tracks: stationTracks.isNotEmpty ? stationTracks : tracks,
          suggestions: const [],
          isLoading: false,
        );
        return;
      }

      // ── Playlist/Album: show immediately, suggestions in background ────
      state = PlaylistDetailState(
        playlist: playlist,
        tracks: tracks,
        suggestions: const [],
        isLoading: false,
        isSuggestionsLoading: playlist.type == PlaylistType.playlist,
      );

      if (playlist.type == PlaylistType.playlist) {
        final suggestions = await _fetchSuggestionsExcluding(tracks);
        state = state.copyWith(
          suggestions: suggestions,
          isSuggestionsLoading: false,
        );
      }
    } on DioException catch (e) {
      print('[DETAIL] ❌ init ${e.response?.statusCode}');
      // Fallback to cache
      final cached = _cache.getById(playlistId);
      if (cached != null) {
        state = PlaylistDetailState(
          playlist: cached,
          tracks: _cache.getTracksFor(playlistId),
          isLoading: false,
          error: 'Showing cached data',
        );
      } else {
        state = const PlaylistDetailState(
          error: 'Could not load playlist',
          isLoading: false,
        );
      }
    }
  }

  // ── ADD SUGGESTION ────────────────────────────────────────────────────────
  Future<void> addSuggestion(PlaylistTrack suggestion) async {
    if (_currentPlaylistId == null) return;

    final optimistic =
        state.suggestions.where((s) => s.id != suggestion.id).toList();
    state = state.copyWith(suggestions: optimistic);

    try {
      await _ds.addTrackToPlaylist(
        playlistId: _currentPlaylistId!,
        trackId: suggestion.id,
      );
      print('[DETAIL] ✅ Added "${suggestion.title}"');

      // Re-fetch from backend — authoritative
      final updatedTracks =
          await _ds.fetchPlaylistTracks(_currentPlaylistId!);

      _cache.clearTracks(_currentPlaylistId!);
      for (final t in updatedTracks) {
        _cache.addTrack(playlistId: _currentPlaylistId!, track: t);
      }

      final freshSuggestions =
          await _fetchSuggestionsExcluding(updatedTracks);

      state = state.copyWith(
        tracks: updatedTracks,
        suggestions: freshSuggestions,
      );
    } on DioException catch (e) {
      print('[DETAIL] ❌ addSuggestion ${e.response?.statusCode}: ${e.response?.data}');
      state = state.copyWith(
        suggestions: [...optimistic, suggestion],
        error: 'Could not add "${suggestion.title}". Try again.',
      );
    }
  }

  // ── REMOVE TRACK ──────────────────────────────────────────────────────────
  Future<void> removeTrack(String trackId) async {
    if (_currentPlaylistId == null) return;

    // Optimistic removal
    final optimistic =
        state.tracks.where((t) => t.id != trackId).toList();
    state = state.copyWith(tracks: optimistic);

    try {
      await _ds.removeTrackFromPlaylist(
        playlistId: _currentPlaylistId!,
        trackId: trackId,
      );
      _cache.removeTrack(
          playlistId: _currentPlaylistId!, trackId: trackId);
      print('[DETAIL] ✅ Removed track $trackId');
    } on DioException catch (e) {
      print('[DETAIL] ❌ removeTrack ${e.response?.statusCode}');
      // Restore from cache on failure
      state = state.copyWith(
          tracks: _cache.getTracksFor(_currentPlaylistId!));
    }
  }

  // ── REFRESH SUGGESTIONS ───────────────────────────────────────────────────
  Future<void> refreshSuggestions() async {
    state = state.copyWith(isSuggestionsLoading: true);
    final fresh = await _fetchSuggestionsExcluding(state.tracks);
    state = state.copyWith(
      suggestions: fresh,
      isSuggestionsLoading: false,
    );
    print('[DETAIL] Refreshed: ${fresh.length} suggestions');
  }

  void toggleLike() => state = state.copyWith(isLiked: !state.isLiked);

  void reload() {
    if (_currentPlaylistId != null) init(_currentPlaylistId!);
  }

  // ── INTERNAL ──────────────────────────────────────────────────────────────

  Future<List<PlaylistTrack>> _fetchSuggestionsExcluding(
    List<PlaylistTrack> existing,
  ) async {
    try {
      return await _ds.fetchRecommendedTracksExcluding(
        excludeIds: existing.map((t) => t.id).toList(),
        limit: 5,
      );
    } catch (e) {
      print('[DETAIL] suggestions failed: $e');
      return [];
    }
  }

  Future<List<PlaylistTrack>> _fetchStationTracks(String artistId) async {
    try {
      return await _ds.fetchStationTracks(artistId, limit: 50);
    } catch (e) {
      print('[DETAIL] station tracks failed: $e');
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