import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/player_state.dart';
import '../../../../core/domain/entities/track_summary.dart';
import 'player_dependency_providers.dart';

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

  Future<void> loadAndPlayQueue(List<TrackSummary> tracks, {int initialIndex = 0}) async {
    await ref.read(loadQueueUseCaseProvider).call(tracks, initialIndex: initialIndex);
    await ref.read(playTrackUseCaseProvider).call();
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