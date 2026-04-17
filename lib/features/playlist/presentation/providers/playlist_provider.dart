// lib/features/playlist/presentation/providers/playlist_provider.dart
//
// Uses ONLY Notifier<State> and NotifierProvider — the same pattern already
// used by PlaylistListNotifier in this file, which compiles successfully.
//
// For the detail provider we avoid family entirely. Instead:
//   - playlistDetailProvider is a single NotifierProvider
//   - The notifier has an init(String playlistId) method
//   - PlaylistDetailScreen calls init() on first build via ref.listen trick
//
// This is the safest approach because it uses zero Riverpod APIs beyond
// what is already proven to compile in this project.

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/playlist_remote_datasource.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Infrastructure
// ─────────────────────────────────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) => apiClient);

final playlistDatasourceProvider = Provider<PlaylistRemoteDatasource>((ref) {
  final dio = ref.watch(apiClientProvider).dio;
  print('[PROVIDER SETUP] PlaylistRemoteDatasource ready');
  return PlaylistRemoteDatasource(dio);
});

final playlistMockSeederProvider = Provider<void>((_) {});

// ═════════════════════════════════════════════════════════════════════════════
// PART 1 — LIBRARY LIST
// ═════════════════════════════════════════════════════════════════════════════

class PlaylistListState {
  const PlaylistListState({
    this.playlists = const [],
    this.stations = const [],
    this.isLoading = false,
    this.error,
  });

  final List<PlaylistEntity> playlists;
  final List<PlaylistEntity> stations;
  final bool isLoading;
  final String? error;

  PlaylistListState copyWith({
    List<PlaylistEntity>? playlists,
    List<PlaylistEntity>? stations,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PlaylistListState(
      playlists: playlists ?? this.playlists,
      stations: stations ?? this.stations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final playlistListProvider =
    NotifierProvider<PlaylistListNotifier, PlaylistListState>(
  PlaylistListNotifier.new,
);

class PlaylistListNotifier extends Notifier<PlaylistListState> {
  @override
  PlaylistListState build() => const PlaylistListState();

  PlaylistRemoteDatasource get _ds => ref.read(playlistDatasourceProvider);

  Future<void> loadPlaylists() async {
    print('[LIST] loadPlaylists()');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final all = await _ds.fetchMyPlaylists(filter: 'created');
      state = state.copyWith(
        playlists: all.where((p) => p.type != PlaylistType.station).toList(),
        isLoading: false,
      );
      print('[LIST] loaded ${state.playlists.length} items ✅');
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e));
    }
  }

  Future<void> loadStations() async {
    print('[LIST] loadStations()');
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final stations = await _ds.fetchStations();
      state = state.copyWith(stations: stations, isLoading: false);
      print('[LIST] loaded ${stations.length} stations ✅');
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: _mapError(e));
    }
  }

  Future<PlaylistEntity> createPlaylist({
    required String name,
    required bool isPublic,
    String subtype = 'playlist',
  }) async {
    print('[LIST] createPlaylist("$name")');
    final created = await _ds.createPlaylist(
      name: name,
      isPublic: isPublic,
      subtype: subtype,
    );
    state = state.copyWith(playlists: [created, ...state.playlists]);
    print('[LIST] created ${created.id} ✅');
    return created;
  }

  Future<void> updatePlaylist({
    required String playlistId,
    String? name,
    bool? isPublic,
    String? description,
    File? coverImageFile,
    String? subtype,
  }) async {
    print('[LIST] updatePlaylist($playlistId)');
    final updated = await _ds.updatePlaylist(
      playlistId: playlistId,
      name: name,
      isPublic: isPublic,
      description: description,
      coverImage: coverImageFile,
      subtype: subtype,
    );
    state = state.copyWith(
      playlists: state.playlists
          .map((p) => p.id == playlistId ? updated : p)
          .toList(),
    );
    print('[LIST] updated $playlistId ✅');
  }

  Future<void> deletePlaylist(String playlistId) async {
    print('[LIST] deletePlaylist($playlistId)');
    await _ds.deletePlaylist(playlistId);
    state = state.copyWith(
      playlists: state.playlists.where((p) => p.id != playlistId).toList(),
    );
    print('[LIST] deleted $playlistId ✅');
  }

  Future<void> convertToAlbum(String id) =>
      updatePlaylist(playlistId: id, subtype: 'album');

  Future<void> convertToPlaylist(String id) =>
      updatePlaylist(playlistId: id, subtype: 'playlist');

  Future<void> convertToStation(String id) async =>
      print('[LIST] convertToStation — no-op');

  void clearError() => state = state.copyWith(clearError: true);

  String _mapError(DioException e) {
    print('[LIST] HTTP ${e.response?.statusCode} — ${e.response?.data}');
    switch (e.response?.statusCode) {
      case 401:
        return 'Please log in again.';
      case 403:
        return 'You don\'t have permission to do that.';
      case 404:
        return 'Playlist not found.';
      case 409:
        return 'Track already in playlist.';
      case 422:
        final code =
            (e.response?.data?['error']?['code'] as String?) ?? '';
        if (code == 'BUSINESS_LIMIT_REACHED') {
          return 'Playlist limit reached. Upgrade to Premium.';
        }
        return 'Invalid request.';
      default:
        return 'Something went wrong. Try again.';
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PART 2 — DETAIL PROVIDER
//
// Uses a plain NotifierProvider (no family) — same as PlaylistListNotifier
// above, which already compiles.
//
// HOW IT WORKS WITHOUT FAMILY:
//   The notifier starts empty. When PlaylistDetailScreen opens, it calls
//   ref.read(playlistDetailProvider.notifier).init(playlistId)
//   which sets the ID and loads data.
//
//   Multiple playlists open at different times? This works because
//   GoRouter creates a new screen instance each time you navigate to a
//   playlist, and the screen calls init() with its own ID immediately.
//   The provider state resets to loading when init() is called with a
//   new ID.
// ═════════════════════════════════════════════════════════════════════════════

class PlaylistDetailState {
  const PlaylistDetailState({
    this.playlist,
    this.tracks = const [],
    this.suggestions = const [],
    this.isLoading = false,
    this.showSuggestions = false,
    this.error,
    this.loadedForId,
  });

  final PlaylistEntity? playlist;
  final List<PlaylistTrack> tracks;
  final List<PlaylistTrack> suggestions;
  final bool isLoading;
  final bool showSuggestions;
  final String? error;
  // Tracks which playlist ID is currently loaded — used to avoid
  // re-fetching if the same screen rebuilds without changing playlist.
  final String? loadedForId;

  PlaylistDetailState copyWith({
    PlaylistEntity? playlist,
    List<PlaylistTrack>? tracks,
    List<PlaylistTrack>? suggestions,
    bool? isLoading,
    bool? showSuggestions,
    String? error,
    bool clearError = false,
    String? loadedForId,
  }) {
    return PlaylistDetailState(
      playlist: playlist ?? this.playlist,
      tracks: tracks ?? this.tracks,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      error: clearError ? null : (error ?? this.error),
      loadedForId: loadedForId ?? this.loadedForId,
    );
  }
}

final playlistDetailProvider =
    NotifierProvider<PlaylistDetailNotifier, PlaylistDetailState>(
  PlaylistDetailNotifier.new,
);

class PlaylistDetailNotifier extends Notifier<PlaylistDetailState> {
  @override
  PlaylistDetailState build() => const PlaylistDetailState();

  PlaylistRemoteDatasource get _ds => ref.read(playlistDatasourceProvider);

  // ── Called by PlaylistDetailScreen, EditPlaylistSheet, PlaylistOptionsSheet
  // Pass the playlistId. If it's already loaded for that ID, does nothing.
  Future<void> init(String playlistId) async {
    if (state.loadedForId == playlistId && !state.isLoading) {
      print('[DETAIL] init($playlistId) — already loaded, skipping');
      return;
    }
    await _load(playlistId);
  }

  Future<void> _load(String playlistId) async {
    print('[DETAIL] loading $playlistId');
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      loadedForId: playlistId,
    );
    try {
      final results = await Future.wait([
        _ds.fetchPlaylistDetail(playlistId),
        _ds.fetchPlaylistTracks(playlistId),
      ]);

      final playlist = results[0] as PlaylistEntity;
      final tracks = results[1] as List<PlaylistTrack>;
      final showSuggestions = tracks.length < 3;

      state = state.copyWith(
        playlist: playlist,
        tracks: tracks,
        isLoading: false,
        showSuggestions: showSuggestions,
        loadedForId: playlistId,
      );
      print('[DETAIL] "${playlist.name}" — ${tracks.length} tracks ✅');

      if (showSuggestions) _loadSuggestions(playlistId);
    } on DioException catch (e) {
      print('[DETAIL] load failed ${e.response?.statusCode}');
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load playlist.',
      );
    }
  }

  Future<void> _loadSuggestions(String playlistId) async {
    print('[DETAIL] loading suggestions');
    try {
      final suggested = await _ds.fetchRecommendedTracks(limit: 5);
      // Only apply if we're still on the same playlist
      if (state.loadedForId == playlistId) {
        state = state.copyWith(suggestions: suggested, showSuggestions: true);
        print('[DETAIL] ${suggested.length} suggestions ✅');
      }
    } on DioException catch (_) {
      print('[DETAIL] suggestions failed — non-fatal');
    }
  }

  Future<void> toggleLike() async {
    final playlist = state.playlist;
    if (playlist == null) return;
    final playlistId = state.loadedForId!;
    final nowLiked = !playlist.isLiked;
    state = state.copyWith(playlist: playlist.copyWith(isLiked: nowLiked));
    try {
      if (nowLiked) {
        await _ds.likePlaylist(playlistId);
      } else {
        await _ds.unlikePlaylist(playlistId);
      }
      print('[DETAIL] toggleLike → $nowLiked ✅');
    } on DioException catch (e) {
      print('[DETAIL] toggleLike failed, reverting: ${e.response?.statusCode}');
      state = state.copyWith(playlist: playlist.copyWith(isLiked: !nowLiked));
    }
  }

  Future<void> addSuggestion(PlaylistTrack track) async {
    final playlistId = state.loadedForId;
    if (playlistId == null) return;
    print('[DETAIL] addSuggestion "${track.title}"');
    try {
      await _ds.addTrackToPlaylist(playlistId: playlistId, trackId: track.id);
      state = state.copyWith(
        tracks: [...state.tracks, track],
        suggestions: state.suggestions.where((s) => s.id != track.id).toList(),
        showSuggestions: (state.tracks.length + 1) < 3,
      );
      print('[DETAIL] suggestion added ✅');
    } on DioException catch (e) {
      print('[DETAIL] addSuggestion failed: ${e.response?.statusCode}');
    }
  }

  Future<void> refreshSuggestions() async {
    final playlistId = state.loadedForId;
    if (playlistId == null) return;
    print('[DETAIL] refreshSuggestions()');
    state = state.copyWith(suggestions: []);
    await _loadSuggestions(playlistId);
  }

  Future<void> removeTrack(String trackId) async {
    final playlistId = state.loadedForId;
    if (playlistId == null) return;
    print('[DETAIL] removeTrack $trackId');
    try {
      await _ds.removeTrackFromPlaylist(
          playlistId: playlistId, trackId: trackId);
      state = state.copyWith(
        tracks: state.tracks.where((t) => t.id != trackId).toList(),
      );
      print('[DETAIL] track removed ✅');
    } on DioException catch (e) {
      print('[DETAIL] removeTrack failed: ${e.response?.statusCode}');
    }
  }

  Future<void> reload() async {
    final playlistId = state.loadedForId;
    if (playlistId == null) return;
    print('[DETAIL] reload()');
    await _load(playlistId);
  }
}