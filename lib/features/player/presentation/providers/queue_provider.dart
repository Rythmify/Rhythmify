import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/queue_state.dart';
import '../../domain/entities/queue_item.dart';
import 'player_provider.dart';
import 'player_dependency_providers.dart';
import '../../../track/presentation/providers/track_dependency_providers.dart';

final queueStateProvider = NotifierProvider<QueueNotifier, AppQueueState>(() {
  return QueueNotifier();
});

class QueueNotifier extends Notifier<AppQueueState> {
  String? _lastFetchedRelatedId;

  @override
  AppQueueState build() {
    ref.listen(playerStateProvider, (previous, next) {
      // ── Unified Reactive Logic ─────────────────────────────────────────────
      // We react differently depending on WHAT changed in the player.

      final oldId = previous?.currentTrack?.id;
      final newId = next.currentTrack?.id;
      final oldIndex = previous?.queueIndex;
      final newIndex = next.queueIndex;

      // 1. TRACK CHANGED (Auto-advance or Skip)
      // We sync state and check if we need to fetch more recommendations.
      if (oldId != newId && newId != null) {
        _syncWithHardware(newIndex ?? 0);
        _checkAndFetchRelated();
      }
      // 2. INDEX CHANGED (Same track, different position in hardware queue)
      // This happens during reorders or manual queue syncs. We just sync state.
      else if (oldIndex != newIndex && newIndex != null) {
        _syncWithHardware(newIndex);
      }
    });

    return const AppQueueState();
  }

  /// Synchronizes the Riverpod state and the Backend exactly with the hardware.
  void _syncWithHardware(int nativeIndex) {
    // 1. Flatten the current UI lists into one absolute truth.
    final allItems = [
      ...state.history,
      if (state.currentTrack != null) state.currentTrack!,
      ...state.upcomingTracks,
    ];

    if (nativeIndex < 0 || nativeIndex >= allItems.length) {
      // Safety: If hardware is ahead of UI (rare), we can't slice correctly.
      return;
    }

    // 2. Slice exactly at the index provided by the hardware.
    final newHistory = allItems.sublist(0, nativeIndex);
    final newCurrent = allItems[nativeIndex];
    final newUpcoming = allItems.sublist(nativeIndex + 1);

    state = state.copyWith(
      history: newHistory,
      currentTrack: newCurrent,
      upcomingTracks: newUpcoming,
      unShuffledUpcomingTracks: newUpcoming,
    );

    // 3. Centralized Backend Sync: Every time the index changes, notify the server.
    ref
        .read(syncPlayerStateUseCaseProvider)
        .call(
          trackId: newCurrent.track.id,
          queue: newUpcoming.map((e) => e.toJson()).toList(),
        );
  }

  /// Proactively fetches discovery tracks BEFORE the manual queue ends.
  Future<void> _checkAndFetchRelated() async {
    final upcoming = state.upcomingTracks;
    final current = state.currentTrack;

    if (current == null) return;

    // Threshold: Fetch when total remaining tracks are 5 or fewer.
    if (upcoming.length <= 5 &&
        !state.isLoadingRecommendations &&
        _lastFetchedRelatedId != current.track.id) {
      _lastFetchedRelatedId = current.track.id;
      state = state.copyWith(isLoadingRecommendations: true);

      try {
        final relatedTracks = await ref
            .read(getRelatedTracksUseCaseProvider)
            .call(current.track.id);

        final existingIds = {
          ...state.history.map((e) => e.track.id),
          ...state.upcomingTracks.map((e) => e.track.id),
          current.track.id,
        };

        final newRelated = relatedTracks
            .where((t) => !existingIds.contains(t.id))
            .map(
              (t) => QueueItem(
                track: t,
                queueBucket: 'context',
                sourceType: 'related',
                sourceId: current.track.id,
                isRecommended: true,
              ),
            )
            .toList();

        if (newRelated.isNotEmpty) {
          // Hardware sync
          await ref
              .read(appendTracksUseCaseProvider)
              .call(newRelated.map((e) => e.track).toList());

          // UI sync
          state = state.copyWith(
            upcomingTracks: [...state.upcomingTracks, ...newRelated],
            isLoadingRecommendations: false,
          );
        } else {
          state = state.copyWith(isLoadingRecommendations: false);
        }
      } catch (e) {
        debugPrint('[QueueNotifier] Proactive fetch failed: $e');
        state = state.copyWith(isLoadingRecommendations: false);
      }
    }
  }

  /// Commands the native player. The UI state will update reactively via build().
  Future<void> playQueue({
    required List<Track> tracks,
    required int initialIndex,
    QueueContext? context,
  }) async {
    if (tracks.isEmpty || initialIndex < 0 || initialIndex >= tracks.length) {
      return;
    }

    final tappedTrack = tracks[initialIndex];
    _lastFetchedRelatedId = null;

    final localItems = tracks.asMap().entries.map((entry) {
      final t = entry.value;
      final idx = entry.key;
      return QueueItem(
        track: t,
        queueItemId:
            'opt_${t.id}_${DateTime.now().millisecondsSinceEpoch}_$idx',
      );
    }).toList();

    final history = localItems.sublist(0, initialIndex);
    final currentItem = localItems[initialIndex];
    final upcoming = localItems.sublist(initialIndex + 1);

    // Set initial state. build() listener will handle subsequent changes.
    state = state.copyWith(
      context: context,
      history: history,
      currentTrack: currentItem,
      upcomingTracks: upcoming,
      unShuffledUpcomingTracks: upcoming,
      isShuffled: false,
    );

    await ref
        .read(playerStateProvider.notifier)
        .loadAndPlayQueue(tracks, initialIndex: initialIndex);

    if (context == null || context.type == QueueSource.unknown) return;

    try {
      final response = await ref
          .read(fetchQueueContextUseCaseProvider)
          .call(
            interactionType: 'play',
            sourceType: context.type.name,
            sourceId: context.sourceId,
            targetUserId: context.targetUserId,
          );

      final data = response['data'] as Map<String, dynamic>;
      final rawQueue = data['queue'] as List<dynamic>;
      final List<QueueItem> fullContextItems = rawQueue
          .map((item) => QueueItem.fromJson(item as Map<String, dynamic>))
          .toList();

      final actualIndexInContext = fullContextItems.indexWhere(
        (item) => item.track.id == tappedTrack.id,
      );

      if (actualIndexInContext != -1) {
        final allServerTracks = fullContextItems.map((e) => e.track).toList();

        // Command hardware with full context
        await ref
            .read(playerStateProvider.notifier)
            .updateNativeQueue(allServerTracks, newIndex: actualIndexInContext);

        // Update local state to match server's truth
        state = state.copyWith(
          history: fullContextItems.sublist(0, actualIndexInContext),
          currentTrack: fullContextItems[actualIndexInContext],
          upcomingTracks: fullContextItems.sublist(actualIndexInContext + 1),
        );
      }
    } catch (_) {}
  }

  /// Command hardware only.
  void nextTrack() => ref.read(playerStateProvider.notifier).skipToNext();

  /// Command hardware only.
  void previousTrack() =>
      ref.read(playerStateProvider.notifier).skipToPrevious();

  /// Command hardware only.
  void skipToIndex(int index) {
    ref.read(playerStateProvider.notifier).skipToAbsoluteIndex(index);
  }

  /// Command hardware only.
  void playFromQueue(int index) {
    // index here is relative to upcomingTracks.
    // Absolute index = history.length + 1 + index
    final absoluteIndex = state.history.length + 1 + index;
    skipToIndex(absoluteIndex);
  }

  /// Command hardware only.
  void playFromRecommended(int index) {
    final allUpcoming = state.upcomingTracks;
    final recommendedItems = allUpcoming.where((t) => t.isRecommended).toList();
    if (index < 0 || index >= recommendedItems.length) return;

    final targetItem = recommendedItems[index];
    final globalIndexInUpcoming = allUpcoming.indexOf(targetItem);

    if (globalIndexInUpcoming != -1) {
      playFromQueue(globalIndexInUpcoming);
    }
  }

  void toggleShuffle() {
    if (state.upcomingTracks.isEmpty) return;

    if (state.isShuffled) {
      state = state.copyWith(
        isShuffled: false,
        upcomingTracks: List.from(state.unShuffledUpcomingTracks),
      );
    } else {
      final shuffled = List<QueueItem>.from(state.upcomingTracks)..shuffle();
      state = state.copyWith(
        isShuffled: true,
        unShuffledUpcomingTracks: List.from(state.upcomingTracks),
        upcomingTracks: shuffled,
      );
    }

    // Hardware sync for shuffle
    final allTracks = [
      ...state.history.map((e) => e.track),
      state.currentTrack!.track,
      ...state.upcomingTracks.map((e) => e.track),
    ];
    ref.read(playerStateProvider.notifier).updateNativeQueue(allTracks);
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= state.upcomingTracks.length) {
      return;
    }
    final list = List<QueueItem>.from(state.upcomingTracks);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    state = state.copyWith(
      upcomingTracks: list,
      unShuffledUpcomingTracks: list,
    );

    // Calculate absolute indices for the hardware (History + Current + index)
    final int hardwareOldIndex = state.history.length + 1 + oldIndex;
    final int hardwareNewIndex = state.history.length + 1 + newIndex;

    // Seamless hardware sync using moveTrack (prevents playback restart)
    ref
        .read(playerStateProvider.notifier)
        .moveTrack(hardwareOldIndex, hardwareNewIndex);
  }

  /// Adds a single track immediately after the current playing track.
  Future<void> addToQueueNext(Track track) async {
    await addMultipleToQueueNext([track]);
  }

  /// Adds multiple tracks immediately after the current playing track.
  Future<void> addMultipleToQueueNext(List<Track> tracks) async {
    if (tracks.isEmpty) return;

    if (state.currentTrack == null) {
      await playQueue(tracks: tracks, initialIndex: 0);
      return;
    }

    final newItems = tracks.asMap().entries.map((entry) {
      final t = entry.value;
      final idx = entry.key;
      return QueueItem(
        track: t,
        queueItemId:
            'manual_${t.id}_${DateTime.now().millisecondsSinceEpoch}_$idx',
      );
    }).toList();

    final currentUpcoming = List<QueueItem>.from(state.upcomingTracks);
    currentUpcoming.insertAll(0, newItems);

    state = state.copyWith(
      upcomingTracks: currentUpcoming,
      unShuffledUpcomingTracks: currentUpcoming,
    );

    await _syncHardwareQueue();

    // Background resolution for skeletons
    for (final item in newItems) {
      if (item.track.userId.isEmpty || item.track.waveformData == null) {
        _resolveTrackInBackground(item);
      }
    }
  }

  /// Adds a single track to the very end of the manual queue (before recommendations).
  Future<void> addToQueueLast(Track track) async {
    await addMultipleToQueueLast([track]);
  }

  /// Adds multiple tracks to the very end of the manual queue (before recommendations).
  Future<void> addMultipleToQueueLast(List<Track> tracks) async {
    if (tracks.isEmpty) return;

    if (state.currentTrack == null) {
      await playQueue(tracks: tracks, initialIndex: 0);
      return;
    }

    final newItems = tracks.asMap().entries.map((entry) {
      final t = entry.value;
      final idx = entry.key;
      return QueueItem(
        track: t,
        queueItemId:
            'manual_${t.id}_${DateTime.now().millisecondsSinceEpoch}_$idx',
      );
    }).toList();

    final currentUpcoming = List<QueueItem>.from(state.upcomingTracks);
    final firstRecIndex = currentUpcoming.indexWhere(
      (item) => item.isRecommended,
    );

    if (firstRecIndex == -1) {
      currentUpcoming.addAll(newItems);
    } else {
      currentUpcoming.insertAll(firstRecIndex, newItems);
    }

    state = state.copyWith(
      upcomingTracks: currentUpcoming,
      unShuffledUpcomingTracks: currentUpcoming,
    );

    await _syncHardwareQueue();

    for (final item in newItems) {
      if (item.track.userId.isEmpty || item.track.waveformData == null) {
        _resolveTrackInBackground(item);
      }
    }
  }

  /// Fetches full track details and updates the queue item in place.
  Future<void> _resolveTrackInBackground(QueueItem item) async {
    try {
      final fullTrack = await ref
          .read(getTrackDetailsUseCaseProvider)
          .call(item.track.id);

      // We might also want waveform data while we are at it
      final waveform = await ref
          .read(getWaveformUseCaseProvider)
          .call(item.track.id)
          .catchError((_) => <double>[]);

      final resolvedTrack = fullTrack.copyWith(
        waveformData: waveform.isNotEmpty ? waveform : fullTrack.waveformData,
      );

      final updatedUpcoming = state.upcomingTracks.map((it) {
        if (it.queueItemId == item.queueItemId) {
          return it.copyWith(track: resolvedTrack);
        }
        return it;
      }).toList();

      state = state.copyWith(
        upcomingTracks: updatedUpcoming,
        unShuffledUpcomingTracks: updatedUpcoming,
      );
    } catch (e) {
      debugPrint('[QueueNotifier] Background resolution failed: $e');
    }
  }

  /// Helper to sync the entire local state to the native hardware player.
  Future<void> _syncHardwareQueue() async {
    if (state.currentTrack == null) return;

    final allTracks = [
      ...state.history.map((e) => e.track),
      state.currentTrack!.track,
      ...state.upcomingTracks.map((e) => e.track),
    ];
    await ref.read(playerStateProvider.notifier).updateNativeQueue(allTracks);
  }

  Future<void> addToNextUp({
    required String sourceType,
    String? sourceId,
  }) async {
    try {
      final response = await ref
          .read(fetchQueueContextUseCaseProvider)
          .call(
            interactionType: 'next_up',
            sourceType: sourceType,
            sourceId: sourceId,
          );

      final data = response['data'] as Map<String, dynamic>;
      final rawQueue = data['queue'] as List<dynamic>;
      final newItems = rawQueue
          .map((item) => QueueItem.fromJson(item as Map<String, dynamic>))
          .toList();

      final currentUpcoming = List<QueueItem>.from(state.upcomingTracks);
      final firstRecommendedIndex = currentUpcoming.indexWhere(
        (t) => t.isRecommended,
      );

      if (firstRecommendedIndex == -1) {
        currentUpcoming.insertAll(0, newItems);
      } else {
        currentUpcoming.insertAll(firstRecommendedIndex, newItems);
      }

      state = state.copyWith(
        upcomingTracks: currentUpcoming,
        unShuffledUpcomingTracks: currentUpcoming,
      );

      final allTracks = [
        ...state.history.map((e) => e.track),
        state.currentTrack!.track,
        ...state.upcomingTracks.map((e) => e.track),
      ];
      await ref.read(playerStateProvider.notifier).updateNativeQueue(allTracks);
    } catch (_) {}
  }
}
