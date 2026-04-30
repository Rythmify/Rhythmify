import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/entities/history_record.dart';
import '../../../../core/domain/entities/track.dart';
import 'player_dependency_providers.dart';
import '../../../track/presentation/providers/track_dependency_providers.dart';

/// Provides the current [AppPlayerState] and exposes methods to control playback.
final playerStateProvider = NotifierProvider<PlayerNotifier, AppPlayerState>(()
  {
    return PlayerNotifier();
  },
);

///  state strictly for the UI to track the seek bar while dragging
final seekDragPositionProvider = NotifierProvider<SeekDragNotifier, Duration?>(()
  {
    return SeekDragNotifier();
  },
);

class SeekDragNotifier extends Notifier<Duration?>
{
  @override
  Duration? build() => null;

  void setPosition(Duration? position) {
    state = position;
  }
}

/// Manages the [AppPlayerState] and coordinates playback actions.
class PlayerNotifier extends Notifier<AppPlayerState> {
  bool _isDragging = false;

  DateTime? _recentLocalSeek;

  // Tracking for listening history
  final Stopwatch _sessionStopwatch = Stopwatch();
  String? _sessionTrackId;
  DateTime? _sessionStartTime;

  // These track the queue locally since AppPlayerState has no queue field.
  final List<Track> _queue = [];
  int _currentIndex = 0;


  @override
  AppPlayerState build() {
    final getStreamUseCase = ref.read(getPlayerStateStreamUseCaseProvider);

    // Sync pending history on startup
    ref.read(syncHistoryUseCaseProvider).call();

    // Listen to the domain stream and update the presentation state.
    final subscription = getStreamUseCase.call().listen((newState) {

      if (!ref.mounted) return;

      final oldTrackId = state.currentTrack?.id;
      final newTrackId = newState.currentTrack?.id;

      // If the UI is actively dragging, preserve the frozen position in state.
      if (_isDragging){
        state = newState.copyWith(position: state.position);
      }
      else {

        final bool suppressRecentLocalSeek =_recentLocalSeek != null &&
            DateTime.now().difference(_recentLocalSeek!) < const Duration(milliseconds: 600);

        if (suppressRecentLocalSeek) {
          state = newState.copyWith(position: state.position);
        }
        else {
          state = newState;
        }
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
      }
      else {
        if (_sessionStopwatch.isRunning) _sessionStopwatch.stop();
      }

      // Fetch additional track details if needed
      if (newTrackId != null && newTrackId != oldTrackId) {
        if (newState.currentTrack?.waveformData == null) {
          _updateTrackInBackground(newTrackId);
        }
      }

      // Clear the local seek suppression if stream position has caught up
      if (_recentLocalSeek != null) {
        if (newState.position.inMilliseconds >=
            (state.position.inMilliseconds)) {
          _recentLocalSeek = null;
        }
      }
    });

    ref.onDispose(subscription.cancel);

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
  }) async
  {
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

    _queue
      ..clear()
      ..addAll(updatedTracks);
    _currentIndex = initialIndex;

    await ref
        .read(loadQueueUseCaseProvider)
        .call(updatedTracks, initialIndex: initialIndex);
    await ref.read(playTrackUseCaseProvider).call();
  }

  /// Inserts [track] immediately after the currently playing track.
  /// If nothing is playing, starts a new queue with this track.
  Future<void> addToQueueNext(Track track) async {
    if (state.currentTrack == null) {
      await loadAndPlayQueue([track]);
      return;
    }
    Track resolved = track;
    try {
      final url = await ref
          .read(initiatePlaybackUseCaseProvider)
          .call(track.id);
      resolved = track.copyWith(streamUrl: url);
    } catch (_) {}
    _queue.insert(_currentIndex + 1, resolved);
    await ref
        .read(loadQueueUseCaseProvider)
        .call(List<Track>.from(_queue), initialIndex: _currentIndex);
  }

  /// Appends [track] to the end of the current queue.
  /// If nothing is playing, starts a new queue with this track.
  Future<void> addToQueueLast(Track track) async {
    if (state.currentTrack == null)
    {
      await loadAndPlayQueue([track]);
      return;
    }
    Track resolved = track;

    try {
      final url = await ref
          .read(initiatePlaybackUseCaseProvider)
          .call(track.id);
      resolved = track.copyWith(streamUrl: url);
    }
    catch (_) {}
    _queue.add(resolved);
    await ref
        .read(loadQueueUseCaseProvider)
        .call(List<Track>.from(_queue), initialIndex: _currentIndex);
  }


  /// Starts playback immediately with partial info and fetches full details in the background.
  Future<void> playOptimistic(Track initialTrack) async {
    // For optimistic play, we still want to call initiate playback
    String? streamUrl;
    try {
      streamUrl = await ref
          .read(initiatePlaybackUseCaseProvider)
          .call(initialTrack.id);
    }
    catch (_) {}

    final trackToPlay = streamUrl != null ? initialTrack.copyWith(streamUrl: streamUrl) : initialTrack;

    await loadAndPlayQueue([trackToPlay]);
    _updateTrackInBackground(initialTrack.id);
  }

  /// Internal helper to fetch full track metadata and waveform data.
  Future<void> _updateTrackInBackground(String trackId) async {
    try {
      // Run both calls concurrently.
      // Note: If one fails, Future.wait will throw immediately.
      // We wrap individual calls to allow partial success if possible,
      // or just catch the whole thing.
      final results = await Future.wait([
        ref.read(getTrackDetailsUseCaseProvider).call(trackId).catchError((e) {
          debugPrint(
            '[PlayerNotifier] Failed to fetch track details for $trackId: $e',
          );
          return state.currentTrack!; // Fallback to existing track info
        }),
        ref.read(getWaveformUseCaseProvider).call(trackId).catchError((e) {
          debugPrint(
            '[PlayerNotifier] Failed to fetch waveform for $trackId: $e',
          );
          return <double>[]; // Fallback to empty waveform
        }),
      ]);

      final fullTrack = results[0] as Track;
      final waveform = results[1] as List<double>;

      // Only update if we actually got new useful info
      if (waveform.isNotEmpty || fullTrack != state.currentTrack) {
        final updatedTrack = fullTrack.copyWith(
          waveformData: waveform.isNotEmpty ? waveform : fullTrack.waveformData,
        );
        await ref
            .read(updateTrackInfoUseCaseProvider)
            .call(trackId, updatedTrack);
      }
    } catch (e) {
      // Catch-all for any other unexpected errors in the background update flow
      debugPrint(
        '[PlayerNotifier] Critical error in _updateTrackInBackground: $e',
      );
    }
  }

  /// Moves to a specific track index in the current native queue.
  Future<void> skipToAbsoluteIndex(int index) async {
    final repository = ref.read(audioRepositoryProvider);
    final nativeQueue = repository.currentQueue;

    if (index < 0 || index >= nativeQueue.length) {
      debugPrint('[PlayerNotifier] skipToAbsoluteIndex out of bounds: $index');
      return;
    }

    final targetTrack = nativeQueue[index];

    // Safety Net: If the track somehow lacks a URL (e.g. discovery race condition),
    // resolve it just-in-time before skipping.
    if ((targetTrack.streamUrl ?? targetTrack.audioUrl).isEmpty) {
      debugPrint(
        '[PlayerNotifier] targetTrack at $index lacks URL. Resolving JIT...',
      );
      try {
        final streamUrl = await ref
            .read(initiatePlaybackUseCaseProvider)
            .call(targetTrack.id);
        final resolvedTrack = targetTrack.copyWith(streamUrl: streamUrl);

        // Update both local mirror and hardware metadata
        _queue[index] = resolvedTrack;
        await repository.updateTrackInfo(targetTrack.id, resolvedTrack);
      } catch (e) {
        debugPrint(
          '[PlayerNotifier] JIT URL resolution failed for ${targetTrack.id}: $e',
        );
      }
    }

    await repository.skipToIndex(index);
    await ref.read(playTrackUseCaseProvider).call();
  }

  /// Replaces the native player's queue metadata silently.
  Future<void> updateNativeQueue(List<Track> tracks, {int? newIndex}) async {
    // If a new index is provided, we use loadQueue to sync both list and position
    if (newIndex != null) {
      await ref
          .read(audioRepositoryProvider)
          .loadQueue(tracks, initialIndex: newIndex);
    } else {
      await ref.read(audioRepositoryProvider).updateQueue(tracks);
    }
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
    _markLocalSeekTime();
  }

  void _markLocalSeekTime() {
    _recentLocalSeek = DateTime.now();
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

  /// Loads a preview track directly without calling initiatePlayback.
  /// Used for tap-to-preview in the feed where we already have the previewUrl.
  Future<void> loadAndPlayPreview(Track track) async {
    _queue
      ..clear()
      ..add(track);
    _currentIndex = 0;

    await ref.read(loadQueueUseCaseProvider).call([track], initialIndex: 0);
    await ref.read(playTrackUseCaseProvider).call();

    _updateTrackInBackground(track.id);
  }
}