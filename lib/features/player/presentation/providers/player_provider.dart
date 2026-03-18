import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/player_state.dart';
import '../../../../core/domain/entities/track.dart';
import 'player_dependency_providers.dart';
import '../../../track/presentation/providers/track_dependency_providers.dart';

final playerStateProvider = NotifierProvider<PlayerNotifier, AppPlayerState>(() {
  return PlayerNotifier();
});

class PlayerNotifier extends Notifier<AppPlayerState> {
  @override
  AppPlayerState build()
  {
    final getStreamUseCase = ref.read(getPlayerStateStreamUseCaseProvider);

    getStreamUseCase.call().listen((newState)
    {
      state = newState; // This tell the UI to rebuild
    });

    return const AppPlayerState(); // Initial empty state
  }

  // --- ACTIONS THE UI CAN TRIGGER ---

  Future<void> loadAndPlayQueue(List<Track> tracks, {int initialIndex = 0}) async {
    await ref.read(loadQueueUseCaseProvider).call(tracks, initialIndex: initialIndex);
    await ref.read(playTrackUseCaseProvider).call();
  }

  /// Optimistic Loading Flow:
  /// 1. Immediately starts buffering/playing with basic info.
  /// 2. Concurrently fetches full details, waveform, and tags in background.
  /// 3. Updates state once background calls resolve.
  Future<void> playOptimistic(Track initialTrack) async {
    // Phase 1: Immediate Playback (Optimistic)
    await loadAndPlayQueue([initialTrack]);

    // Phase 2: Background Concurrent Updates
    _updateTrackInBackground(initialTrack.id);
  }

  Future<void> _updateTrackInBackground(String trackId) async {
    try {
      // Trigger background APIs concurrently
      final results = await Future.wait([
        ref.read(getTrackDetailsUseCaseProvider).call(trackId),
        ref.read(getWaveformUseCaseProvider).call(trackId),
      ]);

      final fullTrack = results[0] as Track;
      final waveform = results[1] as List<double>;

      // Since the backend now returns tag NAMES, we just merge directly
      final updatedTrack = fullTrack.copyWith(
        waveformData: waveform,
      );

      // Phase 3: Update State Manager
      await ref.read(updateTrackInfoUseCaseProvider).call(trackId, updatedTrack);

    } catch (e) {
      print('Error updating track info in background: $e');
    }
  }

  void togglePlayPause() {
    if (state.status == PlayerStatus.playing) {
      ref.read(pauseTrackUseCaseProvider).call();
    } else {
      ref.read(playTrackUseCaseProvider).call();
    }
  }

  void skipToNext() {
    ref.read(skipNextUseCaseProvider).call();
  }

  void skipToPrevious() {
    ref.read(skipPrevUseCaseProvider).call();
  }

  void seek(Duration position) {
    ref.read(seekPositionUseCaseProvider).call(position);
  }
}
