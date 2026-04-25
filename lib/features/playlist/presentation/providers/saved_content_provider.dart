// lib/features/playlist/presentation/providers/saved_content_provider.dart
//
// CHANGES vs previous:
//   - likeMix now captures playlist_id from backend response and reloads
//     playlistListProvider so the mix appears in the Liked section of library
//   - likeTrackRadio added: POST /tracks/:id/like-radio → captures playlist_id
//     and reloads playlistListProvider so the radio appears in library
//   - unlikeMix / unlikeTrackRadio added (symmetric)
//   - Station toggle unchanged — was already correct

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/playlist_remote_datasource.dart';
import '../../data/local/local_saved_store.dart';
import 'playlist_provider.dart'; // for playlistListProvider

export '../../data/local/local_saved_store.dart' show SavedMix, SavedStation;

final _ds = PlaylistRemoteDatasource(apiClient.dio);

// ════════════════════════════════════════════════════════════════════════════
// SAVED MIXES
// toggle → POST/DELETE /home/mixes/:id/like
// On like: backend returns playlist_id → reload playlistListProvider
//          so the mix shows up in Library → Playlists → Liked tab
// ════════════════════════════════════════════════════════════════════════════

class SavedMixesNotifier extends AsyncNotifier<List<SavedMix>> {
  @override
  Future<List<SavedMix>> build() async {
    // No GET endpoint for liked mixes — start empty, populate as user likes
    return [];
  }

  Future<void> toggle(SavedMix mix) async {
    final current = state.asData?.value ?? [];
    final isSaved = current.any((m) => m.mixId == mix.mixId);

    // Optimistic update
    if (isSaved) {
      state = AsyncData(current.where((m) => m.mixId != mix.mixId).toList());
    } else {
      state = AsyncData([...current, mix]);
    }

    try {
      if (isSaved) {
        await _ds.unlikeMix(mix.mixId);
        await LocalSavedStore.instance.removeMix(mix.mixId);
      } else {
        await _ds.likeMix(mix.mixId);
        await LocalSavedStore.instance.saveMix(mix);
        // Reload the playlist list so the mix appears in Library → Liked
        // The backend created a real playlist row — fetchMyPlaylists(filter:'liked')
        // will now return it.
        ref.read(playlistListProvider.notifier).loadLikedPlaylists();
      }
    } catch (e) {
      // Rollback on failure
      state = AsyncData(current);
    }
  }
}

final savedMixesProvider =
    AsyncNotifierProvider<SavedMixesNotifier, List<SavedMix>>(
  SavedMixesNotifier.new,
);

// ════════════════════════════════════════════════════════════════════════════
// TRACK RADIO ("More of what you like")
// POST /tracks/:track_id/like-radio → backend returns playlist_id
// On like: reload playlistListProvider so radio appears in Library → Liked
// ════════════════════════════════════════════════════════════════════════════

/// Minimal state to track which track IDs have been radio-saved this session.
/// We don't have a GET /liked-radios endpoint, so this is session-only.
class SavedTrackRadiosNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async => {};

  /// Like or unlike the radio for [trackId].
  /// Returns true if now saved, false if now unsaved.
  Future<bool> toggle(String trackId) async {
    final current = state.asData?.value ?? {};
    final isSaved = current.contains(trackId);

    // Optimistic update
    if (isSaved) {
      state = AsyncData(Set.from(current)..remove(trackId));
    } else {
      state = AsyncData(Set.from(current)..add(trackId));
    }

    try {
      if (isSaved) {
        await _ds.unlikeTrackRadio(trackId);
      } else {
        await _ds.likeTrackRadio(trackId);
        // Reload playlist list — backend created a track_radio playlist row
        ref.read(playlistListProvider.notifier).loadLikedPlaylists();
      }
      return !isSaved;
    } catch (e) {
      // Rollback
      state = AsyncData(current);
      return isSaved;
    }
  }

  bool isSaved(String trackId) => state.asData?.value.contains(trackId) ?? false;
}

final savedTrackRadiosProvider =
    AsyncNotifierProvider<SavedTrackRadiosNotifier, Set<String>>(
  SavedTrackRadiosNotifier.new,
);

// ════════════════════════════════════════════════════════════════════════════
// SAVED STATIONS
// build → GET /users/me/stations
// toggle → POST/DELETE /stations/:artistId/like then refresh
// ════════════════════════════════════════════════════════════════════════════

class SavedStationsNotifier extends AsyncNotifier<List<SavedStation>> {
  @override
  Future<List<SavedStation>> build() async {
    return await _ds.fetchSavedStations();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _ds.fetchSavedStations());
  }

  Future<void> toggle(SavedStation station) async {
    final current = state.asData?.value ?? [];
    final isSaved = current.any((s) => s.artistId == station.artistId);

    // Optimistic update
    if (isSaved) {
      state = AsyncData(
        current.where((s) => s.artistId != station.artistId).toList(),
      );
    } else {
      state = AsyncData([...current, station]);
    }

    try {
      if (isSaved) {
        await _ds.unlikeStation(station.artistId);
      } else {
        await _ds.likeStation(station.artistId);
      }
      // Always sync with real backend state after action
      await refresh();
    } catch (e) {
      // Rollback
      state = AsyncData(current);
    }
  }
}

final savedStationsProvider =
    AsyncNotifierProvider<SavedStationsNotifier, List<SavedStation>>(
  SavedStationsNotifier.new,
);