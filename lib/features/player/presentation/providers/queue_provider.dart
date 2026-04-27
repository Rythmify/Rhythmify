import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/queue_state.dart';
import '../../domain/entities/queue_item.dart';
import 'player_provider.dart';
import 'player_dependency_providers.dart';

final queueStateProvider = NotifierProvider<QueueNotifier, AppQueueState>(() {
  return QueueNotifier();
});

class QueueNotifier extends Notifier<AppQueueState> {
  String? _lastFetchedRelatedId;
  bool _isSyncing = false;

  @override
  AppQueueState build() {
    ref.listen(playerStateProvider, (previous, next) {
      if (_isSyncing) return;

      if (previous?.currentTrack?.id != next.currentTrack?.id &&
          next.currentTrack != null) {
        _syncWithPlayer(next.currentTrack!);
        _checkAndFetchRelated();
      }
    });

    return const AppQueueState();
  }

  /// Automatically fetches related tracks when the queue is near the end.
  Future<void> _checkAndFetchRelated() async {
    final upcoming = state.upcomingTracks;
    final current = state.currentTrack;

    if (current == null) return;

    // Trigger if 3 or fewer tracks left in the TOTAL native queue
    if (upcoming.length <= 3 &&
        !state.isLoadingRecommendations &&
        _lastFetchedRelatedId != current.track.id) {
      
      _lastFetchedRelatedId = current.track.id;
      
      state = state.copyWith(isLoadingRecommendations: true);

      try {
        final relatedTracks = await ref.read(getRelatedTracksUseCaseProvider).call(current.track.id);

        final existingIds = {
          ...state.history.map((e) => e.track.id),
          ...state.upcomingTracks.map((e) => e.track.id),
          current.track.id,
        };

        final newRelated = relatedTracks
            .where((t) => !existingIds.contains(t.id))
            .map((t) => QueueItem(
                  track: t,
                  queueBucket: 'context',
                  sourceType: 'related',
                  sourceId: current.track.id,
                  isRecommended: true,
                ))
            .toList();

        if (newRelated.isNotEmpty) {
          // 1. Append to native player queue
          await ref.read(appendTracksUseCaseProvider).call(newRelated.map((e) => e.track).toList());

          // 2. Append to local state
          state = state.copyWith(
            upcomingTracks: [...state.upcomingTracks, ...newRelated],
            isLoadingRecommendations: false,
          );
        } else {
          state = state.copyWith(isLoadingRecommendations: false);
        }
      } catch (e) {
        debugPrint('[QueueNotifier] Failed to auto-fetch related tracks: $e');
        state = state.copyWith(isLoadingRecommendations: false);
      }
    }
  }

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

    // --- STEP 1: OPTIMISTIC LOCAL UI ---
    final localItems = tracks.map((t) => QueueItem(track: t)).toList();
    final history = localItems.sublist(0, initialIndex);
    final currentItem = localItems[initialIndex];
    final upcoming = localItems.sublist(initialIndex + 1);

    state = state.copyWith(
      context: context,
      history: history,
      currentTrack: currentItem,
      upcomingTracks: upcoming,
      unShuffledUpcomingTracks: upcoming,
      isShuffled: false,
    );

    // Command native player
    await ref
        .read(playerStateProvider.notifier)
        .loadAndPlayQueue(tracks, initialIndex: initialIndex);

    // --- STEP 2: BACKGROUND CONTEXT FETCH ---
    if (context == null || context.type == QueueSource.unknown) return;

    try {
      final response = await ref.read(fetchQueueContextUseCaseProvider).call(
        interactionType: 'play',
        sourceType: context.type.name,
        sourceId: context.sourceId,
        targetUserId: context.targetUserId,
      );

      final data = response['data'] as Map<String, dynamic>;
      final rawQueue = data['queue'] as List<dynamic>;

      final List<QueueItem> fullContextItems =
          rawQueue.map((item) => QueueItem.fromJson(item as Map<String, dynamic>)).toList();

      final actualIndexInContext = fullContextItems.indexWhere(
        (item) => item.track.id == tappedTrack.id,
      );

      if (actualIndexInContext != -1) {
        final serverHistory = fullContextItems.sublist(0, actualIndexInContext);
        final serverCurrent = fullContextItems[actualIndexInContext];
        final serverUpcoming = fullContextItems.sublist(actualIndexInContext + 1);

        // Sync native player with full resolved context
        final allServerTracks = fullContextItems.map((e) => e.track).toList();
        await ref.read(playerStateProvider.notifier).updateNativeQueue(
          allServerTracks,
          newIndex: actualIndexInContext,
        );

        state = state.copyWith(
          history: serverHistory,
          currentTrack: serverCurrent,
          upcomingTracks: serverUpcoming,
          unShuffledUpcomingTracks: serverUpcoming,
        );
      }
    } catch (e) {
      // Background fetch failed
    }
  }

  void _syncWithPlayer(Track activeTrack) {
    if (state.currentTrack?.track.id == activeTrack.id) return;

    final newHistory = List<QueueItem>.from(state.history);
    if (state.currentTrack != null) {
      newHistory.add(state.currentTrack!);
    }

    final newUpcoming = List<QueueItem>.from(state.upcomingTracks);
    QueueItem? nextItem;

    final indexInUpcoming = newUpcoming.indexWhere((t) => t.track.id == activeTrack.id);

    if (indexInUpcoming != -1) {
      // Move skipped items to history
      for (int i = 0; i < indexInUpcoming; i++) {
        newHistory.add(newUpcoming[i]);
      }
      nextItem = newUpcoming[indexInUpcoming];
      newUpcoming.removeRange(0, indexInUpcoming + 1);
    } else {
      nextItem = QueueItem(track: activeTrack);
    }

    state = state.copyWith(
      history: newHistory,
      currentTrack: nextItem,
      upcomingTracks: newUpcoming,
      unShuffledUpcomingTracks: newUpcoming,
    );
  }

  void nextTrack() => ref.read(playerStateProvider.notifier).skipToNext();

  void previousTrack() {
    if (state.history.isEmpty) {
      ref.read(playerStateProvider.notifier).seek(Duration.zero);
      return;
    }
    ref.read(playerStateProvider.notifier).skipToPrevious();
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
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || newIndex < 0 || oldIndex >= state.upcomingTracks.length) {
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
  }

  void playFromQueue(int index) {
    if (index < 0 || index >= state.upcomingTracks.length) return;

    final targetItem = state.upcomingTracks[index];
    _isSyncing = true;
    
    final newHistory = List<QueueItem>.from(state.history);
    if (state.currentTrack != null) newHistory.add(state.currentTrack!);
    newHistory.addAll(state.upcomingTracks.sublist(0, index));

    final newUpcoming = state.upcomingTracks.sublist(index + 1);

    state = state.copyWith(
      history: newHistory,
      currentTrack: targetItem,
      upcomingTracks: newUpcoming,
      unShuffledUpcomingTracks: newUpcoming,
    );

    ref.read(playerStateProvider.notifier).skipToAbsoluteIndex(newHistory.length).then((_) {
      _isSyncing = false;
    });

    ref.read(syncPlayerStateUseCaseProvider).call(
      trackId: targetItem.track.id,
      queue: newUpcoming.map((e) => e.toJson()).toList(),
    );
  }

  /// Since recommendations are part of upcomingTracks now, we can remove 
  /// playFromRecommended or alias it to playFromQueue.
  void playFromRecommended(int index) {
    // We find all recommended items currently in upcomingTracks
    final allUpcoming = state.upcomingTracks;
    final recommendedItems = allUpcoming.where((t) => t.isRecommended).toList();

    if (index < 0 || index >= recommendedItems.length) return;

    final targetItem = recommendedItems[index];
    final globalIndexInUpcoming = allUpcoming.indexOf(targetItem);

    if (globalIndexInUpcoming != -1) {
      playFromQueue(globalIndexInUpcoming);
    }
  }

  void skipToIndex(int index) {
    final allItems = [
      ...state.history,
      if (state.currentTrack != null) state.currentTrack!,
      ...state.upcomingTracks,
    ];

    if (index < 0 || index >= allItems.length) return;

    final targetItem = allItems[index];
    if (targetItem.track.id == state.currentTrack?.track.id) return;

    _isSyncing = true;

    final newHistory = allItems.sublist(0, index);
    final newUpcoming = allItems.sublist(index + 1);

    state = state.copyWith(
      history: newHistory,
      currentTrack: targetItem,
      upcomingTracks: newUpcoming,
      unShuffledUpcomingTracks: newUpcoming,
    );

    ref.read(playerStateProvider.notifier).skipToAbsoluteIndex(index).then((_) {
      _isSyncing = false;
    });

    ref.read(syncPlayerStateUseCaseProvider).call(
      trackId: targetItem.track.id,
      queue: newUpcoming.map((e) => e.toJson()).toList(),
    );
  }

  Future<void> addToNextUp({
    required String sourceType,
    String? sourceId,
  }) async {
    try {
      final response = await ref.read(fetchQueueContextUseCaseProvider).call(
        interactionType: 'next_up',
        sourceType: sourceType,
        sourceId: sourceId,
      );

      final data = response['data'] as Map<String, dynamic>;
      final rawQueue = data['queue'] as List<dynamic>;

      final newItems =
          rawQueue.map((item) => QueueItem.fromJson(item as Map<String, dynamic>)).toList();

      // Insert at the front of upcoming, but BEFORE recommended tracks if they exist
      final currentUpcoming = List<QueueItem>.from(state.upcomingTracks);
      final firstRecommendedIndex = currentUpcoming.indexWhere((t) => t.isRecommended);
      
      if (firstRecommendedIndex == -1) {
        currentUpcoming.insertAll(0, newItems);
      } else {
        currentUpcoming.insertAll(firstRecommendedIndex, newItems);
      }

      state = state.copyWith(
        upcomingTracks: currentUpcoming,
        unShuffledUpcomingTracks: currentUpcoming,
      );
      
      // Update native player
      final allTracks = [
        ...state.history.map((e) => e.track),
        state.currentTrack!.track,
        ...state.upcomingTracks.map((e) => e.track),
      ];
      await ref.read(playerStateProvider.notifier).updateNativeQueue(allTracks);
      
    } catch (e) {
      // Fallback
    }
  }
}
