// lib/features/playlist/presentation/providers/playlist_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/domain/entities/track.dart';
import '../../data/datasources/playlist_remote_datasource.dart';
import '../../data/mock/playlist_mock_data.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/playlist_track.dart';

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

  Duration get totalDuration =>
      tracks.fold(Duration.zero, (acc, t) => acc + t.duration);

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
  PlaylistListState build() => const PlaylistListState(isLoading: true);

  final _cache = PlaylistMockData.instance;
  PlaylistRemoteDatasource get _ds => ref.read(playlistDatasourceProvider);

  // ── LOAD CREATED (owned) ──────────────────────────────────────────────────
  // fromJsonListOwned ensures isOwned=true on every playlist returned here.
  Future<void> loadPlaylists() async {
    state = state.copyWith(isLoading: true);
    try {
      final playlists = await _ds.fetchMyPlaylists(filter: 'created');
      _cache.syncFromBackend(playlists);
      state = PlaylistListState(playlists: playlists);
      debugPrint('[LIST] ✅ Loaded ${playlists.length} owned playlists  '
          'isOwned check: ${playlists.firstOrNull?.isOwned}');
    } on DioException catch (_) {
      state = PlaylistListState(
        playlists: _cache.getMyPlaylists(),
        error: 'Could not refresh playlists',
      );
    }
  }

  // ── LOAD LIKED ────────────────────────────────────────────────────────────
  // GET /me/liked-playlists — correct endpoint for mixes + liked playlists.
  // All returned with isOwned=false.
  Future<void> loadLikedPlaylists() async {
    state = state.copyWith(isLoading: true);
    try {
      final playlists = await _ds.fetchLikedPlaylists();
      state = PlaylistListState(playlists: playlists);
      debugPrint('[LIST] ✅ Loaded ${playlists.length} liked playlists');
    } on DioException catch (_) {
      state = PlaylistListState(
        playlists: [],
        error: 'Could not load liked playlists',
      );
    }
  }

  // ── LOAD LIKED ALBUMS ─────────────────────────────────────────────────────
  Future<void> loadLikedAlbums() async {
    state = state.copyWith(isLoading: true);
    try {
      final liked = await _ds.fetchMyPlaylists(filter: 'liked');
      state = PlaylistListState(playlists: liked);
    } on DioException catch (_) {
      state = PlaylistListState(
        playlists: [],
        error: 'Could not load liked albums',
      );
    }
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<PlaylistEntity?> createPlaylist({
    required String name,
    required bool isPublic,
  }) async {
    try {
      final created =
          await _ds.createPlaylist(name: name, isPublic: isPublic);
      _cache.createWithId(
        id: created.id,
        name: created.name,
        isPublic: created.isPublic,
        ownerName: created.ownerName,
        ownerId: created.ownerId,
      );
      await loadPlaylists();
      return created;
    } catch (e) {
      return null;
    }
  }

  // ── COPY PLAYLIST ─────────────────────────────────────────────────────────
  Future<String?> copyPlaylist(String playlistId) async {
    final original = _cache.getById(playlistId);
    if (original == null) return null;
    final copyName = 'Copy of ${original.name}';
    try {
      final created = await _ds.createPlaylist(
        name: copyName,
        isPublic: original.isPublic,
      );
      final tracks = await _ds.fetchPlaylistTracks(playlistId);
      for (final track in tracks) {
        try {
          await _ds.addTrackToPlaylist(
            playlistId: created.id,
            trackId: track.id,
          );
        } catch (_) {}
      }
      _cache.createWithId(
        id: created.id,
        name: created.name,
        isPublic: created.isPublic,
        ownerName: created.ownerName,
        ownerId: created.ownerId,
      );
      await loadPlaylists();
      return created.id;
    } catch (e) {
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
    } catch (e) {
      debugPrint('[LIST] ❌ updatePlaylist: $e');
    }
  }

  // ── UPDATE COVER ──────────────────────────────────────────────────────────
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
    } catch (e) {
      debugPrint('[LIST] ❌ deletePlaylist: $e');
    }
  }

  // ── CONVERT TO ALBUM ──────────────────────────────────────────────────────
  Future<void> convertToAlbum(String playlistId) async {
    try {
      await _ds.updatePlaylist(
        playlistId: playlistId,
        subtype: 'album',
        releaseDate: '${DateTime.now().year}-01-01',
      );
      _cache.convertToAlbum(playlistId);
      await loadPlaylists();
    } catch (e) {
      debugPrint('[LIST] ❌ convertToAlbum: $e');
    }
  }

  // ── CONVERT TO PLAYLIST ───────────────────────────────────────────────────
  Future<void> convertToPlaylist(String playlistId) async {
    try {
      await _ds.updatePlaylist(playlistId: playlistId, subtype: 'playlist');
      _cache.convertToPlaylist(playlistId);
      await loadPlaylists();
    } catch (e) {
      debugPrint('[LIST] ❌ convertToPlaylist: $e');
    }
  }

  // ── CONVERT TO STATION ────────────────────────────────────────────────────
  Future<void> convertToStation(String playlistId) async {
    try {
      final existingTracks = _cache.getTracksFor(playlistId);
      final playlist = _cache.getById(playlistId);

      final relatedResults = await Future.wait(
        existingTracks.map((t) => _ds.fetchRelatedTracks(t.id, limit: 50)),
      );

      final seenIds = <String>{};
      final merged = <PlaylistTrack>[];

      for (final t in existingTracks) {
        if (seenIds.add(t.id)) merged.add(t);
      }
      for (final batch in relatedResults) {
        for (final t in batch) {
          if (seenIds.add(t.id)) merged.add(t);
        }
      }

      final seeds = merged.take(existingTracks.length).toList();
      final related = merged.skip(existingTracks.length).toList()..shuffle();
      final station58 = [...seeds, ...related].take(58).toList();

      _cache.convertToStation(playlistId,
          seedArtistName: playlist?.ownerName);
      _cache.clearTracks(playlistId);
      for (int i = 0; i < station58.length; i++) {
        _cache.addTrack(
          playlistId: playlistId,
          track: station58[i].copyWith(position: i + 1),
        );
      }

      await loadPlaylists();
    } catch (e) {
      debugPrint('[LIST] ❌ convertToStation: $e');
    }
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

  Future<void> init(String playlistId) async {
    _currentPlaylistId = playlistId;
    state = const PlaylistDetailState(isLoading: true);

    try {
      // Step 1: fetch playlist metadata
      final playlist = await _ds.fetchPlaylistDetail(playlistId);

      debugPrint('[DETAIL] playlist: "${playlist.name}" '
          'isOwned: ${playlist.isOwned} '
          'type: ${playlist.type}');

      // Step 2: fetch tracks using the correct endpoint based on playlist type.
      //
      // ROUTING LOGIC:
      // • isOwned = true  → regular owned playlist → GET /playlists/:id/tracks
      // • isOwned = false AND type = station → GET /home/stations/:id/tracks
      // • isOwned = false AND everything else → GET /playlists/:id/tracks
      //   (works for liked regular playlists, mixes stored as playlists, etc.)
      //   If that returns empty, fall back to GET /home/mixes/:id
      //
      // NOTE: fetchPlaylistDetail does NOT set isOwned because it comes from
      // a generic /playlists/:id endpoint. isOwned is set at list-load time.
      // So for the detail screen, we trust the isOwner param passed from the
      // router (which reflects how the tile was tapped) rather than playlist.isOwned.

      List<PlaylistTrack> tracks = [];

      if (playlist.type == PlaylistType.station) {
        // Station — use station tracks endpoint
        if (playlist.seedArtistName != null) {
          tracks = await _fetchStationTracks(playlist.seedArtistName!);
        } else {
          tracks = await _ds.fetchPlaylistTracks(playlistId);
        }
      } else {
        // Regular or generated playlist — try /playlists/:id/tracks first
        tracks = await _ds.fetchPlaylistTracks(playlistId);

        if (tracks.isEmpty) {
          // Empty — could be a generated mix. Try /home/mixes/:id as fallback.
          debugPrint(
              '[DETAIL] tracks empty, trying fetchMixTracks as fallback');
          final mixTracks = await _ds.fetchMixTracks(playlistId);
          if (mixTracks.isNotEmpty) {
            tracks = mixTracks;
            debugPrint('[DETAIL] ✅ Got ${tracks.length} tracks from mix fallback');
          }
        }
      }

      // Cache for offline fallback
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

      debugPrint('[DETAIL] ✅ "${playlist.name}" — ${tracks.length} tracks');

      state = PlaylistDetailState(
        playlist: playlist,
        tracks: tracks,
        isLiked: playlist.isLiked,
        isLoading: false,
        // Only load suggestions for owned playlists (isOwner comes from router extra)
        // We use tracks.isEmpty as a proxy for "new playlist that needs suggestions"
        isSuggestionsLoading: false,
      );

      // Load suggestions only if this looks like an owned playlist
      // (tracks == 0 and type == playlist suggests a newly created one)
      if (playlist.type == PlaylistType.playlist && tracks.isEmpty) {
        state = state.copyWith(isSuggestionsLoading: true);
        final suggestions = await _fetchSuggestionsExcluding(tracks);
        state = state.copyWith(
          suggestions: suggestions,
          isSuggestionsLoading: false,
        );
      }
    } on DioException catch (e) {
      debugPrint('[DETAIL] ❌ init ${e.response?.statusCode}');
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

  // Called from PlaylistDetailScreen when isOwner=true to show suggestions
  Future<void> loadSuggestionsIfOwner() async {
    if (state.suggestions.isNotEmpty || state.isSuggestionsLoading) return;
    state = state.copyWith(isSuggestionsLoading: true);
    final suggestions = await _fetchSuggestionsExcluding(state.tracks);
    state = state.copyWith(
      suggestions: suggestions,
      isSuggestionsLoading: false,
    );
  }

  Future<void> toggleLike() async {
    if (_currentPlaylistId == null) return;
    final wasLiked = state.playlist?.isLiked ?? false;

    state = state.copyWith(
      playlist: state.playlist?.copyWith(isLiked: !wasLiked),
    );

    try {
      if (wasLiked) {
        await _ds.unlikePlaylist(_currentPlaylistId!);
      } else {
        await _ds.likePlaylist(_currentPlaylistId!);
      }
    } catch (e) {
      state = state.copyWith(
        playlist: state.playlist?.copyWith(isLiked: wasLiked),
      );
    }
  }

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
      state = state.copyWith(
        suggestions: [...optimistic, suggestion],
        error:
            'Could not add "${suggestion.title}". Try again.',
      );
      debugPrint('[DETAIL] ❌ addSuggestion ${e.response?.statusCode}');
    }
  }

  Future<void> removeTrack(String trackId) async {
    if (_currentPlaylistId == null) return;

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
    } on DioException catch (_) {
      state = state.copyWith(
          tracks: _cache.getTracksFor(_currentPlaylistId!));
    }
  }

  Future<void> refreshSuggestions() async {
    state = state.copyWith(isSuggestionsLoading: true);
    final fresh = await _fetchSuggestionsExcluding(state.tracks);
    state = state.copyWith(
        suggestions: fresh, isSuggestionsLoading: false);
  }

  void reload() {
    if (_currentPlaylistId != null) init(_currentPlaylistId!);
  }

  Future<List<PlaylistTrack>> _fetchSuggestionsExcluding(
      List<PlaylistTrack> existing) async {
    try {
      return await _ds.fetchRecommendedTracksExcluding(
        excludeIds: existing.map((t) => t.id).toList(),
        limit: 5,
      );
    } catch (_) {
      return [];
    }
  }

  Future<List<PlaylistTrack>> _fetchStationTracks(String artistId) async {
    try {
      return await _ds.fetchStationTracks(artistId, limit: 50);
    } catch (_) {
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