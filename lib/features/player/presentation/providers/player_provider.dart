import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/player_state.dart';
import '../../../../core/domain/entities/track.dart';
import 'player_dependency_providers.dart';
import '../../../track/presentation/providers/track_dependency_providers.dart';

final playerStateProvider = NotifierProvider<PlayerNotifier, AppPlayerState>(
  () {
    return PlayerNotifier();
  },
);

class PlayerNotifier extends Notifier<AppPlayerState> {
  @override
  AppPlayerState build() {
    final getStreamUseCase = ref.read(getPlayerStateStreamUseCaseProvider);

    getStreamUseCase.call().listen((newState) {
      state = newState; // This tell the UI to rebuild
    });

    return const AppPlayerState(); // Initial empty state
  }

  Future<void> loadAndPlayQueue(
    List<Track> tracks, {
    int initialIndex = 0,
  }) async {
    await ref
        .read(loadQueueUseCaseProvider)
        .call(tracks, initialIndex: initialIndex);
    await ref.read(playTrackUseCaseProvider).call();
  }

  ///==========================================================================
  ///  ----------------------- Optimistic Loading Flow -----------------------
  /// 1. Immediately starts buffering/playing with basic info.
  /// 2. Concurrently fetches full details, waveform, and tags in background.
  /// 3. Updates state once background calls resolve.
  ///==========================================================================

  Future<void> playOptimistic(Track initialTrack) async {
    await loadAndPlayQueue([initialTrack]); // Immediate Playback
    _updateTrackInBackground(initialTrack.id); // Background Concurrent Updates
  }

  Future<void> _updateTrackInBackground(String trackId) async {
    final results = await Future.wait([
      ref.read(getTrackDetailsUseCaseProvider).call(trackId),
      ref.read(getWaveformUseCaseProvider).call(trackId),
    ]);

    final fullTrack = results[0] as Track;
    final waveform = results[1] as List<double>;
    final updatedTrack = fullTrack.copyWith(waveformData: waveform);
    await ref
        .read(updateTrackInfoUseCaseProvider)
        .call(trackId, updatedTrack); // Update State Manager
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
