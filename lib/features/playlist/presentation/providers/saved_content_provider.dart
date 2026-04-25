// lib/features/playlist/presentation/providers/saved_content_provider.dart
//
// FIX: After liking a mix or track radio, we call loadLikedPlaylists() so
// the item appears in Library → Playlists → Liked tab.
//
// WHY: The backend creates a real playlist row on like. That row is returned
// by GET /playlists?mine=true&filter=liked. The library "Liked" tab calls
// loadLikedPlaylists() when selected — but if the user is already on that
// tab, the state is stale. By awaiting the reload inside toggle(), the state
// updates immediately without user needing to switch tabs.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/playlist_remote_datasource.dart';
import '../../data/local/local_saved_store.dart';
import 'playlist_provider.dart';

export '../../data/local/local_saved_store.dart' show SavedMix, SavedStation;

final _ds = PlaylistRemoteDatasource(apiClient.dio);

// ════════════════════════════════════════════════════════════════════════════
// SAVED MIXES  (mixed_for_you, made_for_you)
// POST/DELETE /home/mixes/:id/like
// On like → backend creates playlist row → reload liked playlists in library
// ════════════════════════════════════════════════════════════════════════════

class SavedMixesNotifier extends AsyncNotifier<List<SavedMix>> {
  @override
  Future<List<SavedMix>> build() async => [];

  Future<void> toggle(SavedMix mix) async {
    final current = state.asData?.value ?? [];
    final isSaved = current.any((m) => m.mixId == mix.mixId);

    // Optimistic UI update
    state = isSaved
        ? AsyncData(current.where((m) => m.mixId != mix.mixId).toList())
        : AsyncData([...current, mix]);

    try {
      if (isSaved) {
        await _ds.unlikeMix(mix.mixId);
        await LocalSavedStore.instance.removeMix(mix.mixId);
      } else {
        await _ds.likeMix(mix.mixId);
        await LocalSavedStore.instance.saveMix(mix);
        // Reload liked playlists — the backend playlist row is now queryable
        await ref.read(playlistListProvider.notifier).loadLikedPlaylists();
      }
    } catch (e) {
      state = AsyncData(current); // rollback
    }
  }
}

final savedMixesProvider =
    AsyncNotifierProvider<SavedMixesNotifier, List<SavedMix>>(
      SavedMixesNotifier.new,
    );

// ════════════════════════════════════════════════════════════════════════════
// TRACK RADIO  (more_of_what_you_like)
// POST/DELETE /tracks/:track_id/like-radio
// On like → backend creates track_radio playlist row → reload liked playlists
// ════════════════════════════════════════════════════════════════════════════

class SavedTrackRadiosNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async => {};

  /// Toggle the radio-save for [trackId]. Returns true if now saved.
  Future<bool> toggle(String trackId) async {
    final current = state.asData?.value ?? {};
    final isSaved = current.contains(trackId);

    state = isSaved
        ? AsyncData(Set.from(current)..remove(trackId))
        : AsyncData(Set.from(current)..add(trackId));

    try {
      if (isSaved) {
        await _ds.unlikeTrackRadio(trackId);
      } else {
        await _ds.likeTrackRadio(trackId);
        // Reload liked playlists — the track_radio playlist row is now queryable
        await ref.read(playlistListProvider.notifier).loadLikedPlaylists();
      }
      return !isSaved;
    } catch (e) {
      state = AsyncData(current); // rollback
      return isSaved;
    }
  }

  bool isSaved(String trackId) =>
      state.asData?.value.contains(trackId) ?? false;
}

final savedTrackRadiosProvider =
    AsyncNotifierProvider<SavedTrackRadiosNotifier, Set<String>>(
      SavedTrackRadiosNotifier.new,
    );

// ════════════════════════════════════════════════════════════════════════════
// SAVED STATIONS  (discover_with_stations)
// POST/DELETE /stations/:artist_id/like
// GET /users/me/stations
// ════════════════════════════════════════════════════════════════════════════

class SavedStationsNotifier extends AsyncNotifier<List<SavedStation>> {
  @override
  Future<List<SavedStation>> build() async => _ds.fetchSavedStations();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _ds.fetchSavedStations());
  }

  Future<void> toggle(SavedStation station) async {
    final current = state.asData?.value ?? [];
    final isSaved = current.any((s) => s.artistId == station.artistId);

    state = isSaved
        ? AsyncData(
            current.where((s) => s.artistId != station.artistId).toList(),
          )
        : AsyncData([...current, station]);

    try {
      if (isSaved) {
        await _ds.unlikeStation(station.artistId);
      } else {
        await _ds.likeStation(station.artistId);
      }
      await refresh(); // always sync from backend after action
    } catch (e) {
      state = AsyncData(current); // rollback
    }
  }
}

final savedStationsProvider =
    AsyncNotifierProvider<SavedStationsNotifier, List<SavedStation>>(
      SavedStationsNotifier.new,
    );
