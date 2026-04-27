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

  Future<void> _checkAndFetchRelated() async {
    final upcoming = state.upcomingTracks;
    final recommended = state.recommendedTracks;
    final current = state.currentTrack;

    if (current == null) return;

    // Trigger if total remaining tracks (Upcoming + Recommended) is 3 or fewer
    if ((upcoming.length + recommended.length) <= 3 &&
        !state.isLoadingRecommendations &&
        _lastFetchedRelatedId != current.track.id) {
      
      _lastFetchedRelatedId = current.track.id;
      
      state = state.copyWith(isLoadingRecommendations: true);

      try {
        final relatedTracks = await ref.read(getRelatedTracksUseCaseProvider).call(current.track.id);

        final existingIds = {
          ...state.history.map((e) => e.track.id),
          ...state.upcomingTracks.map((e) => e.track.id),
          ...state.recommendedTracks.map((e) => e.track.id),
          current.track.id,
        };

        final newRelated = relatedTracks
            .where((t) => !existingIds.contains(t.id))
            .map((t) => QueueItem(
                  track: t,
                  queueBucket: 'context',
                  sourceType: 'related',
                  sourceId: current.track.id,
                ))
            .toList();

        if (newRelated.isNotEmpty) {
          await ref.read(appendTracksUseCaseProvider).call(newRelated.map((e) => e.track).toList());

          state = state.copyWith(
            recommendedTracks: [...state.recommendedTracks, ...newRelated],
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
      recommendedTracks: [],
      isShuffled: false,
    );

    // Command native player instantly
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

      // --- STEP 3: ARRAY SLICING ---
      final actualIndexInContext = fullContextItems.indexWhere(
        (item) => item.track.id == tappedTrack.id,
      );

      if (actualIndexInContext != -1) {
        final serverHistory = fullContextItems.sublist(0, actualIndexInContext);
        final serverCurrent = fullContextItems[actualIndexInContext];
        final serverUpcoming = fullContextItems.sublist(actualIndexInContext + 1);

        // --- STEP 4: BACKEND SYNC ---
        ref.read(syncPlayerStateUseCaseProvider).call(
          trackId: tappedTrack.id,
          queue: serverUpcoming.map((e) => e.toJson()).toList(),
        );

        // --- STEP 5: SYNC NATIVE PLAYER ---
        final allServerTracks = fullContextItems.map((e) => e.track).toList();
        await ref.read(playerStateProvider.notifier).updateNativeQueue(
          allServerTracks,
          newIndex: actualIndexInContext,
        );

        // --- STEP 6: SILENT STATE UPDATE ---
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

      final currentUpcoming = List<QueueItem>.from(state.upcomingTracks);
      final updatedUpcoming = [...newItems, ...currentUpcoming];

      state = state.copyWith(
        upcomingTracks: updatedUpcoming,
        unShuffledUpcomingTracks: updatedUpcoming,
      );
    } catch (e) {
      // Fallback
    }
  }

  void _syncWithPlayer(Track activeTrack) {
    if (state.currentTrack?.track.id == activeTrack.id) return;

    final newHistory = List<QueueItem>.from(state.history);
    if (state.currentTrack != null) {
      newHistory.add(state.currentTrack!);
    }

    final newUpcoming = List<QueueItem>.from(state.upcomingTracks);
    final newRecommended = List<QueueItem>.from(state.recommendedTracks);
    QueueItem? nextItem;

    final upcomingIndex = newUpcoming.indexWhere((t) => t.track.id == activeTrack.id);
    final recommendedIndex = newRecommended.indexWhere((t) => t.track.id == activeTrack.id);

    if (upcomingIndex != -1) {
      for (int i = 0; i < upcomingIndex; i++) {
        newHistory.add(newUpcoming[i]);
      }
      nextItem = newUpcoming[upcomingIndex];
      newUpcoming.removeRange(0, upcomingIndex + 1);
    } 
    else if (recommendedIndex != -1) {
      newHistory.addAll(newUpcoming);
      newUpcoming.clear();

      for (int i = 0; i < recommendedIndex; i++) {
        newHistory.add(newRecommended[i]);
      }
      nextItem = newRecommended[recommendedIndex];
      newRecommended.removeRange(0, recommendedIndex + 1);
    }
    else {
      nextItem = QueueItem(track: activeTrack);
    }

    state = state.copyWith(
      history: newHistory,
      currentTrack: nextItem,
      upcomingTracks: newUpcoming,
      unShuffledUpcomingTracks: newUpcoming,
      recommendedTracks: newRecommended,
    );
  }

  void nextTrack() {
    ref.read(playerStateProvider.notifier).skipToNext();
  }

  void previousTrack() {
    if (state.history.isEmpty) {
      ref.read(playerStateProvider.notifier).seek(Duration.zero);
      return;
    }
    ref.read(playerStateProvider.notifier).skipToPrevious();
  }

  void toggleShuffle() {
    if (state.upcomingTracks.isEmpty && state.recommendedTracks.isEmpty) return;

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

    final absoluteIndex = newHistory.length; 
    ref.read(playerStateProvider.notifier).skipToAbsoluteIndex(absoluteIndex).then((_) {
      _isSyncing = false;
    });

    ref.read(syncPlayerStateUseCaseProvider).call(
      trackId: targetItem.track.id,
      queue: newUpcoming.map((e) => e.toJson()).toList(),
    );
  }

  void playFromRecommended(int index) {
    if (index < 0 || index >= state.recommendedTracks.length) return;

    final targetItem = state.recommendedTracks[index];
    _isSyncing = true; 

    final newHistory = List<QueueItem>.from(state.history);
    if (state.currentTrack != null) newHistory.add(state.currentTrack!);
    newHistory.addAll(state.upcomingTracks);
    newHistory.addAll(state.recommendedTracks.sublist(0, index));

    final remainingRecommended = state.recommendedTracks.sublist(index + 1);

    state = state.copyWith(
      history: newHistory,
      currentTrack: targetItem,
      upcomingTracks: [], 
      unShuffledUpcomingTracks: [],
      recommendedTracks: remainingRecommended,
    );

    ref.read(playerStateProvider.notifier).skipToAbsoluteIndex(newHistory.length).then((_) {
      _isSyncing = false;
    });

    ref.read(syncPlayerStateUseCaseProvider).call(
          trackId: targetItem.track.id,
          queue: remainingRecommended.map((e) => e.toJson()).toList(),
        );
  }

  void skipToIndex(int index) {
    final allItems = [
      ...state.history,
      if (state.currentTrack != null) state.currentTrack!,
      ...state.upcomingTracks,
      ...state.recommendedTracks,
    ];

    if (index < 0 || index >= allItems.length) return;

    final targetItem = allItems[index];
    if (targetItem.track.id == state.currentTrack?.track.id) return;

    _isSyncing = true;

    final newHistory = allItems.sublist(0, index);
    final allRemaining = allItems.sublist(index + 1);
    final nextUpcoming = allRemaining.where((i) => i.sourceType != 'related').toList();
    final nextRecommended = allRemaining.where((i) => i.sourceType == 'related').toList();

    state = state.copyWith(
      history: newHistory,
      currentTrack: targetItem,
      upcomingTracks: nextUpcoming,
      unShuffledUpcomingTracks: nextUpcoming,
      recommendedTracks: nextRecommended,
    );

    ref.read(playerStateProvider.notifier).skipToAbsoluteIndex(index).then((_) {
      _isSyncing = false;
    });

    ref.read(syncPlayerStateUseCaseProvider).call(
      trackId: targetItem.track.id,
      queue: [...nextUpcoming, ...nextRecommended].map((e) => e.toJson()).toList(),
    );
  }
}
