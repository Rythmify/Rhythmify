import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/entities/history_record.dart';
import '../../../../core/domain/entities/track.dart';
import 'player_dependency_providers.dart';
import '../../../track/presentation/providers/track_dependency_providers.dart';

/// Provides the current [AppPlayerState] and exposes methods to control playback.
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
class PlayerNotifier extends Notifier<AppPlayerState> {
  bool _isDragging = false;

  // Tracking for listening history
  final Stopwatch _sessionStopwatch = Stopwatch();
  String? _sessionTrackId;
  DateTime? _sessionStartTime;

  @override
  AppPlayerState build() {
    final getStreamUseCase = ref.read(getPlayerStateStreamUseCaseProvider);

    // Sync pending history on startup
    ref.read(syncHistoryUseCaseProvider).call();

    // Listen to the domain stream and update the presentation state.
    getStreamUseCase.call().listen((newState) {
      final oldTrackId = state.currentTrack?.id;
      final newTrackId = newState.currentTrack?.id;

      if (_isDragging) {
        state = newState.copyWith(position: state.position);
      } else {
        state = newState;
      }

      // Handle track changes for history recording
      if (newTrackId != oldTrackId) {
        _recordCurrentSession();
        if (newTrackId != null) {
          _startNewSession(newTrackId);
        }
      }

      // Sync stopwatch with playing status
      if (newState.status == PlayerStatus.playing) {
        if (!_sessionStopwatch.isRunning) _sessionStopwatch.start();
      } else {
        if (_sessionStopwatch.isRunning) _sessionStopwatch.stop();
      }

      // Fetch additional track details if needed
      if (newTrackId != null && newTrackId != oldTrackId) {
        if (newState.currentTrack?.waveformData == null) {
          _updateTrackInBackground(newTrackId);
        }
      }
    });

    return const AppPlayerState();
  }

  void _startNewSession(String trackId) {
    _sessionTrackId = trackId;
    _sessionStartTime = DateTime.now();
    _sessionStopwatch.reset();
    if (state.status == PlayerStatus.playing) {
      _sessionStopwatch.start();
    }
  }

  void _recordCurrentSession() {
    if (_sessionTrackId != null && _sessionStartTime != null) {
      final playedSeconds = _sessionStopwatch.elapsed.inSeconds;
      if (playedSeconds > 0) {
        final record = HistoryRecord(
          trackId: _sessionTrackId!,
          playedAt: _sessionStartTime!,
          durationPlayedSeconds: playedSeconds,
        );
        ref.read(recordListeningHistoryUseCaseProvider).call(record);
      }
    }
    _sessionStopwatch.stop();
    _sessionStopwatch.reset();
  }

  /// Loads a list of [Track]s and starts playback from [initialIndex].
  Future<void> loadAndPlayQueue(
    List<Track> tracks, {
    int initialIndex = 0,
  }) async {
    // 1. Initiate playback for the first track to get the URL and increment count
    final targetTrack = tracks[initialIndex];
    final updatedTracks = List<Track>.from(tracks);

    try {
      final streamUrl = await ref
          .read(initiatePlaybackUseCaseProvider)
          .call(targetTrack.id);
      updatedTracks[initialIndex] = targetTrack.copyWith(streamUrl: streamUrl);
    } catch (e) {
      // Fallback to existing URL if API fails, or let it throw if critical
    }

    await ref
        .read(loadQueueUseCaseProvider)
        .call(updatedTracks, initialIndex: initialIndex);
    await ref.read(playTrackUseCaseProvider).call();
  }

  /// Starts playback immediately with partial info and fetches full details in the background.
  Future<void> playOptimistic(Track initialTrack) async {
    // For optimistic play, we still want to call initiate playback
    String? streamUrl;
    try {
      streamUrl = await ref
          .read(initiatePlaybackUseCaseProvider)
          .call(initialTrack.id);
    } catch (_) {}

    final trackToPlay = streamUrl != null
        ? initialTrack.copyWith(streamUrl: streamUrl)
        : initialTrack;

    await loadAndPlayQueue([trackToPlay]);
    _updateTrackInBackground(initialTrack.id);
  }

  /// Internal helper to fetch full track metadata and waveform data.
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

  /// This updates the Riverpod state so the artwork moves instantly.
  void updatePosition(Duration position) {
    state = state.copyWith(position: position);
  }

  /// This tells whether i am moving the slider or not
  void setDragging(bool isDragging) {
    _isDragging = isDragging;
  }

  /// Stops active playback for session-level events like sign-out.
  Future<void> stopPlayback() async {
    _recordCurrentSession();
    await ref.read(pauseTrackUseCaseProvider).call();
    await ref.read(seekPositionUseCaseProvider).call(Duration.zero);
  }
}
