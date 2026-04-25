// lib/features/playlist/presentation/providers/saved_content_provider.dart
//
// Riverpod providers for locally-persisted liked content:
//   - savedStationsProvider  → List<SavedStation>
//   - savedMixesProvider     → List<SavedMix>
//
// These are backed by LocalSavedStore (shared_preferences).
// Use these to like/save stations and mixes from RelatedTracksScreen and MixDetailScreen.

library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/local_saved_store.dart';

// ── Saved Stations ────────────────────────────────────────────────────────────

class SavedStationsNotifier extends AsyncNotifier<List<SavedStation>> {
  @override
  Future<List<SavedStation>> build() async {
    return LocalSavedStore.instance.getStations();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    state = AsyncData(await LocalSavedStore.instance.getStations());
  }

  Future<void> save(SavedStation station) async {
    await LocalSavedStore.instance.saveStation(station);
    state = AsyncData(await LocalSavedStore.instance.getStations());
  }

  Future<void> remove(String artistId) async {
    await LocalSavedStore.instance.removeStation(artistId);
    state = AsyncData(await LocalSavedStore.instance.getStations());
  }

  Future<bool> isSaved(String artistId) async {
    return LocalSavedStore.instance.isStationSaved(artistId);
  }

  Future<void> toggle(SavedStation station) async {
    final saved = await LocalSavedStore.instance.isStationSaved(station.artistId);
    if (saved) {
      await remove(station.artistId);
    } else {
      await save(station);
    }
  }
}

final savedStationsProvider =
    AsyncNotifierProvider<SavedStationsNotifier, List<SavedStation>>(
  SavedStationsNotifier.new,
);

// ── Saved Mixes ───────────────────────────────────────────────────────────────

class SavedMixesNotifier extends AsyncNotifier<List<SavedMix>> {
  @override
  Future<List<SavedMix>> build() async {
    return LocalSavedStore.instance.getMixes();
  }

  Future<void> load() async {
    state = const AsyncLoading();
    state = AsyncData(await LocalSavedStore.instance.getMixes());
  }

  Future<void> save(SavedMix mix) async {
    await LocalSavedStore.instance.saveMix(mix);
    state = AsyncData(await LocalSavedStore.instance.getMixes());
  }

  Future<void> remove(String mixId) async {
    await LocalSavedStore.instance.removeMix(mixId);
    state = AsyncData(await LocalSavedStore.instance.getMixes());
  }

  Future<bool> isSaved(String mixId) async {
    return LocalSavedStore.instance.isMixSaved(mixId);
  }

  Future<void> toggle(SavedMix mix) async {
    final saved = await LocalSavedStore.instance.isMixSaved(mix.mixId);
    if (saved) {
      await remove(mix.mixId);
    } else {
      await save(mix);
    }
  }
}

final savedMixesProvider =
    AsyncNotifierProvider<SavedMixesNotifier, List<SavedMix>>(
  SavedMixesNotifier.new,
);