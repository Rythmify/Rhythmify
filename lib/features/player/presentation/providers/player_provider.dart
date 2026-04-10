import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/player_state.dart';
import '../../../../core/domain/entities/track.dart';
import 'player_dependency_providers.dart';
import '../../../track/presentation/providers/track_dependency_providers.dart';

/// Provides the current [AppPlayerState] and exposes methods to control playback.
///
/// This provider is the main entry point for the UI to interact with the audio player.
/// Depends on [getPlayerStateStreamUseCaseProvider].
final playerStateProvider = NotifierProvider<PlayerNotifier, AppPlayerState>(
  () {
    return PlayerNotifier();
  },
);

/// A temporary state strictly for the UI to track the seek bar while dragging.
final seekDragPositionProvider = NotifierProvider<SeekDragNotifier, Duration?>(
  () {
    return SeekDragNotifier();
  },
);

class SeekDragNotifier extends Notifier<Duration?> {
  @override
  Duration? build() => null;

  void setPosition(Duration? position) {
    state = position;
  }
}

/// Manages the [AppPlayerState] and coordinates playback actions.
///
/// The state represents the current playback status, track info, and progress.
/// - [PlayerStatus.loading]: Player is preparing the audio source.
/// - [PlayerStatus.playing]: Audio is currently being emitted.
/// - [PlayerStatus.paused]: Playback is halted at the current position.
class PlayerNotifier extends Notifier<AppPlayerState> {
  bool _isDragging = false;

  @override
  AppPlayerState build() {
    final getStreamUseCase = ref.read(getPlayerStateStreamUseCaseProvider);

    // Listen to the domain stream and update the presentation state.
    getStreamUseCase.call().listen((newState) {
      if (!_isDragging) {
        state = newState;
      }
    });

    return const AppPlayerState();
  }

  /// Loads a list of [Track]s and starts playback from [initialIndex].
  ///
  /// Updates the local state and syncs with the background audio handler.
  Future<void> loadAndPlayQueue(
    List<Track> tracks, {
    int initialIndex = 0,
  }) async {
    await ref
        .read(loadQueueUseCaseProvider)
        .call(tracks, initialIndex: initialIndex);
    await ref.read(playTrackUseCaseProvider).call();
  }

  /// Starts playback immediately with partial info and fetches full details in the background.
  ///
  /// 1. Immediately starts buffering/playing with [initialTrack].
  /// 2. Concurrently fetches full details, waveform, and tags in background.
  /// 3. Updates the player state once full data is retrieved via [UpdateTrackInfoUseCase].
  Future<void> playOptimistic(Track initialTrack) async {
    await loadAndPlayQueue([initialTrack]);
    _updateTrackInBackground(initialTrack.id);
  }

  /// Internal helper to fetch full track metadata and waveform data.
  ///
  /// Uses [getTrackDetailsUseCaseProvider] and [getWaveformUseCaseProvider].
  Future<void> _updateTrackInBackground(String trackId) async {
    final results = await Future.wait([
      ref.read(getTrackDetailsUseCaseProvider).call(trackId),
      ref.read(getWaveformUseCaseProvider).call(trackId),
    ]);

    final fullTrack = results[0] as Track;
    final waveform = results[1] as List<double>;
    final updatedTrack = fullTrack.copyWith(waveformData: waveform);
    await ref.read(updateTrackInfoUseCaseProvider).call(trackId, updatedTrack);
  }

  /// Toggles between playing and paused states.
  void togglePlayPause() {
    if (state.status == PlayerStatus.playing) {
      ref.read(pauseTrackUseCaseProvider).call();
    } else {
      ref.read(playTrackUseCaseProvider).call();
    }
  }

  /// Moves to the next track in the queue.
  void skipToNext() {
    ref.read(skipNextUseCaseProvider).call();
  }

  /// Moves to the previous track in the queue.
  void skipToPrevious() {
    ref.read(skipPrevUseCaseProvider).call();
  }

  /// Seeks to a specific [position] in the current track.
  void seek(Duration position) {
    ref.read(seekPositionUseCaseProvider).call(position);
  }

  /// This updates the Riverpod state so the artwork moves instantly,
  /// but it does NOT trigger an actual audio player seek.
  void updatePosition(Duration position) {
    state = state.copyWith(position: position);
  }

  /// This tells whether i am moving the slider or not
  void setDragging(bool isDragging) {
    _isDragging = isDragging;
  }

  /// Stops active playback for session-level events like sign-out.
  Future<void> stopPlayback() async {
    await ref.read(pauseTrackUseCaseProvider).call();
    await ref.read(seekPositionUseCaseProvider).call(Duration.zero);
  }
}
