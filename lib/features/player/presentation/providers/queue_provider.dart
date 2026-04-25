import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/queue_state.dart';
import 'player_provider.dart';

final queueStateProvider = NotifierProvider<QueueNotifier, AppQueueState>(() {
  return QueueNotifier();
});

class QueueNotifier extends Notifier<AppQueueState> {
  @override
  AppQueueState build() {
    // Optionally: listen to playerStateProvider to keep queue in sync with native auto-advancement
    ref.listen(playerStateProvider, (previous, next) {
      if (previous?.currentTrack?.id != next.currentTrack?.id &&
          next.currentTrack != null) {
        _syncWithPlayer(next.currentTrack!);
      }
    });

    // Rehydrate from local storage here if implemented

    return const AppQueueState();
  }

  void playQueue({
    required List<Track> tracks,
    required int initialIndex,
    QueueContext? context,
  }) {
    if (tracks.isEmpty || initialIndex < 0 || initialIndex >= tracks.length) {
      return;
    }

    final history = tracks.sublist(0, initialIndex);
    final currentTrack = tracks[initialIndex];
    final upcomingTracks = tracks.sublist(initialIndex + 1);

    state = state.copyWith(
      context: context,
      history: history,
      currentTrack: currentTrack,
      upcomingTracks: upcomingTracks,
      unShuffledUpcomingTracks: upcomingTracks,
      isShuffled: false,
      currentPage: 1,
    );

    // Command the native player
    ref
        .read(playerStateProvider.notifier)
        .loadAndPlayQueue(tracks, initialIndex: initialIndex);
  }

  void _syncWithPlayer(Track activeTrack) {
    if (state.currentTrack?.id == activeTrack.id) return;

    // Track advanced automatically (e.g. by native queue)
    final newHistory = List<Track>.from(state.history);
    if (state.currentTrack != null) {
      newHistory.add(state.currentTrack!);
    }

    final newUpcoming = List<Track>.from(state.upcomingTracks);
    if (newUpcoming.isNotEmpty && newUpcoming.first.id == activeTrack.id) {
      newUpcoming.removeAt(0);
    }

    state = state.copyWith(
      history: newHistory,
      currentTrack: activeTrack,
      upcomingTracks: newUpcoming,
    );
  }

  void nextTrack() {
    if (state.upcomingTracks.isEmpty) return;

    // We can rely on PlayerNotifier to natively skip to next.
    // The ref.listen above will handle our local queue state update once the native player actually advances.
    ref.read(playerStateProvider.notifier).skipToNext();
  }

  void previousTrack() {
    if (state.history.isEmpty) {
      // Just seek to beginning if no history
      ref.read(playerStateProvider.notifier).seek(Duration.zero);
      return;
    }

    // We rely on native player to go to previous.
    // However, if the native player queue is out of sync or just restarts the track,
    // we might need to handle it. For now, try native.
    ref.read(playerStateProvider.notifier).skipToPrevious();

    // Manual state rollback in case native doesn't emit properly for history
    final newUpcoming = List<Track>.from(state.upcomingTracks);
    if (state.currentTrack != null) {
      newUpcoming.insert(0, state.currentTrack!);
    }

    final newHistory = List<Track>.from(state.history);
    final prevTrack = newHistory.removeLast();

    state = state.copyWith(
      history: newHistory,
      currentTrack: prevTrack,
      upcomingTracks: newUpcoming,
    );
  }

  void toggleShuffle() {
    if (state.upcomingTracks.isEmpty) return;

    if (state.isShuffled) {
      // Restore original order
      state = state.copyWith(
        isShuffled: false,
        upcomingTracks: List.from(state.unShuffledUpcomingTracks),
      );
    } else {
      // Shuffle the upcoming tracks
      final shuffled = List<Track>.from(state.upcomingTracks)..shuffle();
      state = state.copyWith(
        isShuffled: true,
        unShuffledUpcomingTracks: List.from(state.upcomingTracks),
        upcomingTracks: shuffled,
      );
    }

    // Note: Re-injecting to the native player without restarting the current track
    // would require an update to the underlying AudioHandler.
    // For a pure client-side Riverpod prototype, the state updates the UI.
  }

  void appendTracks(List<Track> newTracks) {
    final updatedUpcoming = List<Track>.from(state.upcomingTracks)
      ..addAll(newTracks);

    List<Track> updatedUnshuffled;
    if (state.isShuffled) {
      updatedUnshuffled = List<Track>.from(state.unShuffledUpcomingTracks)
        ..addAll(newTracks);
      // We could optionally shuffle the newly appended tracks into the existing ones
    } else {
      updatedUnshuffled = updatedUpcoming;
    }

    state = state.copyWith(
      upcomingTracks: updatedUpcoming,
      unShuffledUpcomingTracks: updatedUnshuffled,
      currentPage: state.currentPage + 1,
    );

    // Again, syncing to native player queue is complex without resetting current track.
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= state.upcomingTracks.length ||
        newIndex > state.upcomingTracks.length) {
      return;
    }

    final list = List<Track>.from(state.upcomingTracks);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final track = list.removeAt(oldIndex);
    list.insert(newIndex, track);

    state = state.copyWith(upcomingTracks: list);
    // UI updates dynamically
  }

  void playFromQueue(int index) {
    if (index < 0 || index >= state.upcomingTracks.length) return;

    final targetTrack = state.upcomingTracks[index];

    // Prepare all tracks for the native player to reconstruct its queue
    final allTracks = [
      ...state.history,
      if (state.currentTrack != null) state.currentTrack!,
      ...state.upcomingTracks,
    ];

    final globalIndex = state.history.length + 1 + index;

    // Push state immediately
    final newHistory = List<Track>.from(state.history);
    if (state.currentTrack != null) newHistory.add(state.currentTrack!);
    newHistory.addAll(state.upcomingTracks.sublist(0, index));

    final newUpcoming = state.upcomingTracks.sublist(index + 1);

    state = state.copyWith(
      history: newHistory,
      currentTrack: targetTrack,
      upcomingTracks: newUpcoming,
    );

    // Command native player to load the full queue and start at the target index
    ref
        .read(playerStateProvider.notifier)
        .loadAndPlayQueue(allTracks, initialIndex: globalIndex);
  }

  void skipToIndex(int index) {
    final allTracks = [
      ...state.history,
      if (state.currentTrack != null) state.currentTrack!,
      ...state.upcomingTracks,
    ];

    if (index < 0 || index >= allTracks.length) return;

    final targetTrack = allTracks[index];
    if (targetTrack.id == state.currentTrack?.id) return;

    final newHistory = allTracks.sublist(0, index);
    final newUpcoming = allTracks.sublist(index + 1);

    state = state.copyWith(
      history: newHistory,
      currentTrack: targetTrack,
      upcomingTracks: newUpcoming,
    );

    // Command native player to seek to this index in its queue
    // Just re-loading for now as it's the safest way to sync
    ref
        .read(playerStateProvider.notifier)
        .loadAndPlayQueue(allTracks, initialIndex: index);
  }
}
