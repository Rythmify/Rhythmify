// lib/features/playlist/presentation/providers/playlist_provider.dart
//
// CHANGES vs original:
//   + toggleLike() — now calls backend POST/DELETE /playlists/{id}/like
//                    with optimistic update + rollback on failure
//   + copyPlaylist() — creates "Copy of [name]" and copies all tracks
//   + loadLikedPlaylists() — for the library filter

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

  /// Sum of all track durations — shown in header and library tile
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
  }) => PlaylistDetailState(
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
  PlaylistListState build() => const PlaylistListState(isLoading: true);

  final _cache = PlaylistMockData.instance;
  PlaylistRemoteDatasource get _ds => ref.read(playlistDatasourceProvider);

  // ── LOAD ──────────────────────────────────────────────────────────────────
  Future<void> loadPlaylists() async {
    state = state.copyWith(isLoading: true);
    try {
      final playlists = await _ds.fetchMyPlaylists(filter: 'created');
      _cache.syncFromBackend(playlists);
      state = PlaylistListState(playlists: playlists);
    } on DioException catch (_) {
      state = PlaylistListState(
        playlists: _cache.getMyPlaylists(),
        error: 'Could not refresh playlists',
      );
    }
  }

  /// Loads liked playlists from backend — used by library filter
  Future<void> loadLikedPlaylists() async {
    state = state.copyWith(isLoading: true);
    try {
      final playlists = await _ds.fetchMyPlaylists(filter: 'liked');
      state = PlaylistListState(playlists: playlists);
    } on DioException catch (_) {
      state = PlaylistListState(
        playlists: [],
        error: 'Could not load liked playlists',
      );
    }
  }

  /// Loads albums the user has liked — used by library albums "Liked" filter.
  /// Calls GET /playlists?mine=true&filter=liked&is_album_view=true
  Future<void> loadLikedAlbums() async {
    state = state.copyWith(isLoading: true);
    try {
      // fetchMyPlaylists with filter=liked fetches all liked collections.
      // We pass no subtype so the backend returns everything liked,
      // then the screen filters by PlaylistType.album client-side.
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
      final created = await _ds.createPlaylist(name: name, isPublic: isPublic);
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
  /// Creates a new playlist named "Copy of [originalName]" and copies all
  /// tracks from the original into it. Returns the new playlist ID on success.
  Future<String?> copyPlaylist(String playlistId) async {
    final original = _cache.getById(playlistId);
    if (original == null) return null;

    final copyName = 'Copy of ${original.name}';

    try {
      // 1. Create the new playlist
      final created = await _ds.createPlaylist(
        name: copyName,
        isPublic: original.isPublic,
      );

      // 2. Fetch current tracks of original
      final tracks = await _ds.fetchPlaylistTracks(playlistId);

      // 3. Add each track to the copy in order
      for (final track in tracks) {
        try {
          await _ds.addTrackToPlaylist(
            playlistId: created.id,
            trackId: track.id,
          );
        } catch (_) {
          // skip tracks that fail (e.g. c0000 seed IDs)
        }
      }

      // 4. Update local cache and reload list
      _cache.createWithId(
        id: created.id,
        name: created.name,
        isPublic: created.isPublic,
        ownerName: created.ownerName,
        ownerId: created.ownerId,
      );
      await loadPlaylists();

      debugPrint('[LIST] ✅ Copied "$playlistId" → "${created.id}"');
      return created.id;
    } catch (e) {
      debugPrint('[LIST] ❌ copyPlaylist: $e');
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
      debugPrint('[LIST] ✅ Updated $playlistId');
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
      debugPrint('[LIST] ✅ Deleted $playlistId');
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

      _cache.convertToStation(playlistId, seedArtistName: playlist?.ownerName);
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

  // ── INIT ──────────────────────────────────────────────────────────────────
  Future<void> init(String playlistId) async {
    _currentPlaylistId = playlistId;
    state = const PlaylistDetailState(isLoading: true);

    try {
      final results = await Future.wait([
        _ds.fetchPlaylistDetail(playlistId),
        _ds.fetchPlaylistTracks(playlistId),
      ]);

      final playlist = results[0] as PlaylistEntity;
      final tracks = results[1] as List<PlaylistTrack>;

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

      if (playlist.type == PlaylistType.station) {
        final cachedTracks = _cache.getTracksFor(playlistId);
        if (cachedTracks.isNotEmpty) {
          state = PlaylistDetailState(
            playlist: playlist,
            tracks: cachedTracks,
            isLiked: playlist.isLiked,
            isLoading: false,
          );
          return;
        }

        if (playlist.seedArtistName != null) {
          final stationTracks = await _fetchStationTracks(
            playlist.seedArtistName!,
          );
          state = PlaylistDetailState(
            playlist: playlist,
            tracks: stationTracks.isNotEmpty ? stationTracks : tracks,
            isLiked: playlist.isLiked,
            isLoading: false,
          );
          return;
        }

        state = PlaylistDetailState(
          playlist: playlist,
          tracks: tracks,
          isLiked: playlist.isLiked,
          isLoading: false,
        );
        return;
      }

      state = PlaylistDetailState(
        playlist: playlist,
        tracks: tracks,
        isLiked: playlist.isLiked, // ← respect backend isLiked on init
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

  Future<void> toggleLike() async {
    if (_currentPlaylistId == null) return;
    final wasLiked = state.playlist?.isLiked ?? false;

    // Optimistic update
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
      // Rollback on failure
      debugPrint('[DETAIL] toggleLike failed: $e');
      state = state.copyWith(
        playlist: state.playlist?.copyWith(isLiked: wasLiked),
      );
    }
  }

  // ── ADD SUGGESTION ────────────────────────────────────────────────────────
  Future<void> addSuggestion(PlaylistTrack suggestion) async {
    if (_currentPlaylistId == null) return;

    final optimistic = state.suggestions
        .where((s) => s.id != suggestion.id)
        .toList();
    state = state.copyWith(suggestions: optimistic);

    try {
      await _ds.addTrackToPlaylist(
        playlistId: _currentPlaylistId!,
        trackId: suggestion.id,
      );
      debugPrint('[DETAIL] ✅ Added "${suggestion.title}"');

      final updatedTracks = await _ds.fetchPlaylistTracks(_currentPlaylistId!);
      _cache.clearTracks(_currentPlaylistId!);
      for (final t in updatedTracks) {
        _cache.addTrack(playlistId: _currentPlaylistId!, track: t);
      }

      final freshSuggestions = await _fetchSuggestionsExcluding(updatedTracks);
      state = state.copyWith(
        tracks: updatedTracks,
        suggestions: freshSuggestions,
      );
    } on DioException catch (e) {
      debugPrint(
        '[DETAIL] ❌ addSuggestion ${e.response?.statusCode}: ${e.response?.data}',
      );
      state = state.copyWith(
        suggestions: [...optimistic, suggestion],
        error: 'Could not add "${suggestion.title}". Try again.',
      );
    }
  }

  // ── REMOVE TRACK ──────────────────────────────────────────────────────────
  Future<void> removeTrack(String trackId) async {
    if (_currentPlaylistId == null) return;

    final optimistic = state.tracks.where((t) => t.id != trackId).toList();
    state = state.copyWith(tracks: optimistic);

    try {
      await _ds.removeTrackFromPlaylist(
        playlistId: _currentPlaylistId!,
        trackId: trackId,
      );
      _cache.removeTrack(playlistId: _currentPlaylistId!, trackId: trackId);
      debugPrint('[DETAIL] ✅ Removed track $trackId');
    } on DioException catch (e) {
      debugPrint('[DETAIL] ❌ removeTrack ${e.response?.statusCode}');
      state = state.copyWith(tracks: _cache.getTracksFor(_currentPlaylistId!));
    }
  }

  // ── REFRESH SUGGESTIONS ───────────────────────────────────────────────────
  Future<void> refreshSuggestions() async {
    state = state.copyWith(isSuggestionsLoading: true);
    final fresh = await _fetchSuggestionsExcluding(state.tracks);
    state = state.copyWith(suggestions: fresh, isSuggestionsLoading: false);
  }

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
      return [];
    }
  }

  Future<List<PlaylistTrack>> _fetchStationTracks(String artistId) async {
    try {
      return await _ds.fetchStationTracks(artistId, limit: 50);
    } catch (e) {
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
