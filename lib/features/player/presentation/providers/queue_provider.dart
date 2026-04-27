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
  @override
  AppQueueState build() {
    ref.listen(playerStateProvider, (previous, next) {
      if (previous?.currentTrack?.id != next.currentTrack?.id &&
          next.currentTrack != null) {
        _syncWithPlayer(next.currentTrack!);
      }
    });

    return const AppQueueState();
  }

  /// 1. Instant local playback.
  /// 2. Background fetch full context.
  /// 3. Correct local state by slicing around the tapped track.
  /// 4. Correct backend state via syncPlayerState.
  Future<void> playQueue({
    required List<Track> tracks,
    required int initialIndex,
    QueueContext? context,
  }) async {
    if (tracks.isEmpty || initialIndex < 0 || initialIndex >= tracks.length) {
      return;
    }

    final tappedTrack = tracks[initialIndex];

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

    // Command native player instantly
    ref
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

      // Map everything to QueueItems
      final List<QueueItem> fullContextItems =
          rawQueue.map((item) => QueueItem.fromJson(item as Map<String, dynamic>)).toList();

      // --- STEP 3: ARRAY SLICING (The Fix) ---
      // Find where our tapped track exists in the full backend context
      final actualIndexInContext = fullContextItems.indexWhere(
        (item) => item.track.id == tappedTrack.id,
      );

      if (actualIndexInContext != -1) {
        final serverHistory = fullContextItems.sublist(0, actualIndexInContext);
        final serverCurrent = fullContextItems[actualIndexInContext];
        final serverUpcoming = fullContextItems.sublist(actualIndexInContext + 1);

        // --- STEP 4: BACKEND SYNC ---
        // Tell the backend that the user is actually at this track, and send the REMAINING queue.
        ref.read(syncPlayerStateUseCaseProvider).call(
          trackId: tappedTrack.id,
          queue: serverUpcoming.map((e) => e.toJson()).toList(),
        );

        // --- STEP 5: SILENT STATE UPDATE ---
        state = state.copyWith(
          history: serverHistory,
          currentTrack: serverCurrent,
          upcomingTracks: serverUpcoming,
          unShuffledUpcomingTracks: serverUpcoming,
        );
      }
    } catch (e) {
      // Background fetch failed, we keep using the local optimistic queue
    }
  }

  /// Appends tracks to the "next_up" bucket via backend.
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

      // These items are tagged as 'next_up' by the backend
      final newItems =
          rawQueue.map((item) => QueueItem.fromJson(item as Map<String, dynamic>)).toList();

      // Merge into state: Insert right after currently playing, before 'context' items.
      final currentUpcoming = List<QueueItem>.from(state.upcomingTracks);

      // Simple implementation: Put them at the very front of upcoming.
      // This ensures they are played next.
      final updatedUpcoming = [...newItems, ...currentUpcoming];

      state = state.copyWith(
        upcomingTracks: updatedUpcoming,
        unShuffledUpcomingTracks: updatedUpcoming, // Reset unshuffled to reflect new additions
      );
    } catch (e) {
      // Fallback or error handling
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

    if (newUpcoming.isNotEmpty && newUpcoming.first.track.id == activeTrack.id) {
      nextItem = newUpcoming.removeAt(0);
    } else {
      // If native player skipped to something else (e.g. manual tap in notification)
      nextItem = QueueItem(track: activeTrack);
    }

    state = state.copyWith(
      history: newHistory,
      currentTrack: nextItem,
      upcomingTracks: newUpcoming,
    );
  }

  void nextTrack() {
    if (state.upcomingTracks.isEmpty) return;
    ref.read(playerStateProvider.notifier).skipToNext();
  }

  void previousTrack() {
    if (state.history.isEmpty) {
      ref.read(playerStateProvider.notifier).seek(Duration.zero);
      return;
    }

    ref.read(playerStateProvider.notifier).skipToPrevious();

    final newUpcoming = List<QueueItem>.from(state.upcomingTracks);
    if (state.currentTrack != null) {
      newUpcoming.insert(0, state.currentTrack!);
    }

    final newHistory = List<QueueItem>.from(state.history);
    final prevItem = newHistory.removeLast();

    state = state.copyWith(
      history: newHistory,
      currentTrack: prevItem,
      upcomingTracks: newUpcoming,
    );
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
    if (oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= state.upcomingTracks.length ||
        newIndex > state.upcomingTracks.length) {
      return;
    }

    final list = List<QueueItem>.from(state.upcomingTracks);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    state = state.copyWith(
      upcomingTracks: list,
      unShuffledUpcomingTracks: list, // Keeping them in sync for simplicity
    );
  }

  void playFromQueue(int index) {
    if (index < 0 || index >= state.upcomingTracks.length) return;

    final targetItem = state.upcomingTracks[index];

    final allTracks = [
      ...state.history.map((e) => e.track),
      if (state.currentTrack != null) state.currentTrack!.track,
      ...state.upcomingTracks.map((e) => e.track),
    ];

    final globalIndex = state.history.length + 1 + index;

    // Push local state update
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

    // Command native player
    ref
        .read(playerStateProvider.notifier)
        .loadAndPlayQueue(allTracks, initialIndex: globalIndex);

    // Sync to backend that we jumped
    ref.read(syncPlayerStateUseCaseProvider).call(
      trackId: targetItem.track.id,
      queue: newUpcoming.map((e) => e.toJson()).toList(),
    );
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

    final newHistory = allItems.sublist(0, index);
    final newUpcoming = allItems.sublist(index + 1);

    state = state.copyWith(
      history: newHistory,
      currentTrack: targetItem,
      upcomingTracks: newUpcoming,
      unShuffledUpcomingTracks: newUpcoming,
    );

    final allTracks = allItems.map((e) => e.track).toList();

    ref
        .read(playerStateProvider.notifier)
        .loadAndPlayQueue(allTracks, initialIndex: index);

    // Sync to backend
    ref.read(syncPlayerStateUseCaseProvider).call(
      trackId: targetItem.track.id,
      queue: newUpcoming.map((e) => e.toJson()).toList(),
    );
  }
}
