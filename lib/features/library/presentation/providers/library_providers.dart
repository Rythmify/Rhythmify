import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/library_mock_datasource.dart';
import '../../data/datasources/library_remote_datasource_impl.dart';
import '../../data/repositories/library_repository_impl.dart';
import '../../domain/entities/library_entities.dart';
import '../../domain/usecases/library_usecases.dart';

/// Riverpod providers and notifier states for Library feature flows.

// ─────────────────────────────────────────────────────────────────────────────
// Feature flag — flip to false to use real API
// ─────────────────────────────────────────────────────────────────────────────
const bool useLibraryMockData = false;

// ─────────────────────────────────────────────────────────────────────────────
// Infrastructure providers
// ─────────────────────────────────────────────────────────────────────────────

final _libraryDatasourceProvider = Provider(
  (ref) => useLibraryMockData
      ? LibraryMockDatasource()
      : LibraryRemoteDatasourceImpl(client: apiClient),
);

final _libraryRepositoryProvider = Provider(
  (ref) => LibraryRepositoryImpl(
    remoteDatasource: ref.read(_libraryDatasourceProvider),
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// Following state & provider
// ─────────────────────────────────────────────────────────────────────────────

class FollowingState extends Equatable {
  final List<FollowedUser> users;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const FollowingState({
    this.users = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  FollowingState copyWith({
    List<FollowedUser>? users,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) => FollowingState(
    users: users ?? this.users,
    isLoading: isLoading ?? this.isLoading,
    hasMore: hasMore ?? this.hasMore,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [users, isLoading, hasMore, error];
}

/// Manages paginated list of users the authenticated user follows.
///
/// Handles loading, pagination, error states, and unfollow actions.
/// Pagination triggers when scrolling near the bottom of the list.
class FollowingNotifier extends Notifier<FollowingState> {
  late final GetFollowingUseCase _getFollowing;
  late final UnfollowUserLibraryUseCase _unfollow;
  int _page = 1;

  @override
  FollowingState build() {
    final repo = ref.read(_libraryRepositoryProvider);
    _getFollowing = GetFollowingUseCase(repo);
    _unfollow = UnfollowUserLibraryUseCase(repo);
    return const FollowingState(isLoading: false);
  }

  /// Loads the following list with pagination support.
  ///
  /// When [refresh] is true, resets pagination to page 1 and clears existing users.
  /// Otherwise, appends the next page to the existing list.
  /// Returns early if already loading and not refreshing.
  Future<void> load({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;
    if (refresh) {
      _page = 1;
      state = state.copyWith(
        users: [],
        isLoading: true,
        hasMore: true,
        error: null,
      );
    } else {
      state = state.copyWith(isLoading: true);
    }

    final result = await _getFollowing(page: _page, limit: 20);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (users) {
        _page++;
        state = state.copyWith(
          users: refresh ? users : [...state.users, ...users],
          isLoading: false,
          hasMore: users.length == 20,
        );
      },
    );
  }

  /// Unfollows a user and removes them from the list optimistically.
  ///
  /// Updates the list immediately (optimistic update) and reverts on failure.
  Future<void> unfollow(String userId) async {
    final prev = state.users;
    state = state.copyWith(users: prev.where((u) => u.id != userId).toList());
    final result = await _unfollow(userId: userId);
    result.fold((failure) => state = state.copyWith(users: prev), (_) {});
  }
}

final followingProvider = NotifierProvider<FollowingNotifier, FollowingState>(
  () => FollowingNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Playlists state & provider
// ─────────────────────────────────────────────────────────────────────────────

class PlaylistsState extends Equatable {
  final List<LibraryPlaylist> playlists;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const PlaylistsState({
    this.playlists = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  PlaylistsState copyWith({
    List<LibraryPlaylist>? playlists,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) => PlaylistsState(
    playlists: playlists ?? this.playlists,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [playlists, isLoading, isSaving, error];
}

class PlaylistsNotifier extends Notifier<PlaylistsState> {
  late final GetMyPlaylistsUseCase _get;
  late final CreatePlaylistUseCase _create;
  late final DeletePlaylistUseCase _delete;

  @override
  PlaylistsState build() {
    final repo = ref.read(_libraryRepositoryProvider);
    _get = GetMyPlaylistsUseCase(repo);
    _create = CreatePlaylistUseCase(repo);
    _delete = DeletePlaylistUseCase(repo);
    Future.microtask(load);
    return const PlaylistsState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _get();
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (p) => state = state.copyWith(playlists: p, isLoading: false),
    );
  }

  Future<bool> create({
    required String name,
    String? description,
    required bool isPublic,
  }) async {
    state = state.copyWith(isSaving: true);
    final result = await _create(
      name: name,
      description: description,
      isPublic: isPublic,
    );
    return result.fold(
      (f) {
        state = state.copyWith(isSaving: false, error: f.message);
        return false;
      },
      (p) {
        state = state.copyWith(
          playlists: [p, ...state.playlists],
          isSaving: false,
        );
        return true;
      },
    );
  }

  Future<void> delete(String playlistId) async {
    final prev = state.playlists;
    state = state.copyWith(
      playlists: prev.where((p) => p.id != playlistId).toList(),
    );
    final result = await _delete(playlistId: playlistId);
    result.fold(
      (f) => state = state.copyWith(playlists: prev, error: f.message),
      (_) {},
    );
  }
}

final playlistsProvider = NotifierProvider<PlaylistsNotifier, PlaylistsState>(
  () => PlaylistsNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Uploads state & provider
// ─────────────────────────────────────────────────────────────────────────────

class UploadsState extends Equatable {
  final List<UploadedTrack> tracks;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const UploadsState({
    this.tracks = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  UploadsState copyWith({
    List<UploadedTrack>? tracks,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) => UploadsState(
    tracks: tracks ?? this.tracks,
    isLoading: isLoading ?? this.isLoading,
    hasMore: hasMore ?? this.hasMore,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [tracks, isLoading, hasMore];
}

class UploadsNotifier extends Notifier<UploadsState> {
  late GetMyUploadsUseCase _get;
  late ToggleTrackVisibilityUseCase _toggleVis;
  late DeleteTrackUseCase _delete;
  int _page = 1;

  @override
  UploadsState build() {
    final repo = ref.read(_libraryRepositoryProvider);
    _get = GetMyUploadsUseCase(repo);
    _toggleVis = ToggleTrackVisibilityUseCase(repo);
    _delete = DeleteTrackUseCase(repo);
    Future.microtask(load);
    return const UploadsState(isLoading: true);
  }

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      state = state.copyWith(tracks: [], isLoading: true, hasMore: true);
    } else {
      if (!state.hasMore) return;
      state = state.copyWith(isLoading: true);
    }

    final result = await _get(page: _page, limit: 20);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (t) {
        _page++;
        state = state.copyWith(
          tracks: [...state.tracks, ...t],
          isLoading: false,
          hasMore: t.length == 20,
        );
      },
    );
  }

  Future<void> toggleVisibility(String trackId, bool isPublic) async {
    final prev = state.tracks;
    state = state.copyWith(
      tracks: prev
          .map(
            (t) => t.id == trackId
                ? UploadedTrack(
                    track: t.track,
                    isPublic: isPublic,
                    status: t.status,
                  )
                : t,
          )
          .toList(),
    );
    final result = await _toggleVis(trackId: trackId, isPublic: isPublic);
    result.fold(
      (f) => state = state.copyWith(tracks: prev, error: f.message),
      (_) {},
    );
  }

  Future<void> deleteTrack(String trackId) async {
    final prev = state.tracks;
    state = state.copyWith(tracks: prev.where((t) => t.id != trackId).toList());
    final result = await _delete(trackId: trackId);
    result.fold(
      (f) => state = state.copyWith(tracks: prev, error: f.message),
      (_) {},
    );
  }
}

final uploadsProvider = NotifierProvider<UploadsNotifier, UploadsState>(
  () => UploadsNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Likes state & provider
// ─────────────────────────────────────────────────────────────────────────────

class LikesState extends Equatable {
  final List<LikedTrack> tracks;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const LikesState({
    this.tracks = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  LikesState copyWith({
    List<LikedTrack>? tracks,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) => LikesState(
    tracks: tracks ?? this.tracks,
    isLoading: isLoading ?? this.isLoading,
    hasMore: hasMore ?? this.hasMore,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [tracks, isLoading, hasMore, error];
}

class LikesNotifier extends Notifier<LikesState> {
  late final GetLikedTracksLibraryUseCase _get;
  int _page = 1;

  @override
  LikesState build() {
    final repo = ref.read(_libraryRepositoryProvider);
    _get = GetLikedTracksLibraryUseCase(repo);
    Future.microtask(load);
    return const LikesState(isLoading: true);
  }

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      state = state.copyWith(tracks: [], isLoading: true, hasMore: true);
    } else {
      if (!state.hasMore || (state.isLoading && _page > 1)) return;
      state = state.copyWith(isLoading: true);
    }

    final result = await _get(page: _page, limit: 20);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (t) {
        _page++;
        state = state.copyWith(
          tracks: [...state.tracks, ...t],
          isLoading: false,
          hasMore: t.length == 20,
        );
      },
    );
  }
}

final likesProvider = NotifierProvider<LikesNotifier, LikesState>(
  () => LikesNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Insights provider (simple FutureProvider)
// ─────────────────────────────────────────────────────────────────────────────

/// Provides track insights analytics for the authenticated user's uploads.
///
/// Fetches per-track statistics (plays, listeners, likes, reposts) for all
/// tracks uploaded by the current user. Returns a [FutureProvider] that handles
/// loading, error, and data states.
///
/// The widget observing this provider must handle all three [AsyncValue] states:
/// - loading: Shows a spinner
/// - error: Shows error message with retry button
/// - data: Shows insights data or empty state if no uploads exist
final insightsProvider = FutureProvider<List<TrackInsight>>((ref) async {
  final repo = ref.read(_libraryRepositoryProvider);
  final result = await GetMyInsightsUseCase(repo).call();
  return result.fold((f) => throw Exception(f.message), (data) => data);
});

// ─────────────────────────────────────────────────────────────────────────────
// History state & provider
// ─────────────────────────────────────────────────────────────────────────────

class HistoryState extends Equatable {
  final List<RecentlyPlayedEntry> entries;
  final bool isLoading;
  final bool hasMore;
  final bool isClearing;
  final String? error;

  const HistoryState({
    this.entries = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.isClearing = false,
    this.error,
  });

  HistoryState copyWith({
    List<RecentlyPlayedEntry>? entries,
    bool? isLoading,
    bool? hasMore,
    bool? isClearing,
    String? error,
  }) => HistoryState(
    entries: entries ?? this.entries,
    isLoading: isLoading ?? this.isLoading,
    hasMore: hasMore ?? this.hasMore,
    isClearing: isClearing ?? this.isClearing,
    error: error ?? this.error,
  );

  @override
  List<Object?> get props => [entries, isLoading, hasMore, isClearing];
}

class HistoryNotifier extends Notifier<HistoryState> {
  late final GetListeningHistoryUseCase _get;
  late final ClearListeningHistoryUseCase _clear;
  int _page = 1;

  @override
  HistoryState build() {
    final repo = ref.read(_libraryRepositoryProvider);
    _get = GetListeningHistoryUseCase(repo);
    _clear = ClearListeningHistoryUseCase(repo);
    Future.microtask(load);
    return const HistoryState(isLoading: true);
  }

  Future<void> load({bool refresh = false}) async {
    // Prevent concurrent paginated loads which cause duplicated/looping fetches.
    if (refresh) {
      _page = 1;
      state = state.copyWith(entries: [], isLoading: true, hasMore: true);
    } else {
      // If there's no more data, or a load is already in progress for subsequent
      // pages, bail out early.
      if (!state.hasMore || (state.isLoading && _page > 1)) return;
      state = state.copyWith(isLoading: true);
    }

    final result = await _get(page: _page, limit: 20);
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (e) {
        _page++;
        // Filter out any items already present (dedupe by trackId + playedAt)
        final existingKeys = state.entries
            .map((x) => '${x.trackId}-${x.playedAt.millisecondsSinceEpoch}')
            .toSet();
        final newEntries = e
            .where(
              (ne) => !existingKeys.contains(
                '${ne.trackId}-${ne.playedAt.millisecondsSinceEpoch}',
              ),
            )
            .toList();

        state = state.copyWith(
          entries: [...state.entries, ...newEntries],
          isLoading: false,
          hasMore: e.length == 20,
        );
      },
    );
  }

  Future<void> clearHistory() async {
    state = state.copyWith(isClearing: true);
    final result = await _clear();
    result.fold(
      (f) => state = state.copyWith(isClearing: false, error: f.message),
      (_) => state = state.copyWith(
        entries: [],
        isClearing: false,
        hasMore: false,
      ),
    );
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(
  () => HistoryNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Stations provider
// ─────────────────────────────────────────────────────────────────────────────

final stationsProvider = FutureProvider<List<LibraryStation>>((ref) async {
  final repo = ref.read(_libraryRepositoryProvider);
  final result = await GetStationsUseCase(repo).call();
  return result.fold((f) => throw Exception(f.message), (data) => data);
});

