import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/domain/entities/track.dart';

/// A custom [BaseAudioHandler] implementation using [just_audio] to manage
/// background playback and system media controls.
///
/// Deliberately avoids [ConcatenatingAudioSource] because the Windows
/// Media Foundation backend in just_audio_windows triggers a C++ abort()
/// when a playlist source is used. Instead the queue is managed entirely
/// in Dart and individual [AudioSource.uri] sources are set per track.
class RythmifyAudioHandler extends BaseAudioHandler with SeekHandler {
  // Plain AudioPlayer — no AudioLoadConfiguration.
  // Passing Android/Darwin load controls to just_audio_windows also triggers abort().
  final AudioPlayer _player = AudioPlayer();

  /// Dart-managed queue. The native player only ever knows about one track.
  List<Track> _currentQueue = [];

  /// Index of the track the native player is currently loaded with.
  int _currentHardwareIndex = 0;

  /// Broadcasts index changes so [AudioRepositoryImpl] can update its state.
  final _indexController = StreamController<int?>.broadcast();

  RythmifyAudioHandler() {
    _init();
  }

  // ── Initialisation ────────────────────────────────────────────────────────

  void _init() {
    // Auto-advance when the current track finishes.
    _player.processingStateStream.listen((ps) async {
      if (ps == ProcessingState.completed) {
        final next = _currentHardwareIndex + 1;
        if (next < _currentQueue.length) {
          await _loadTrackAtIndex(next);
        }
      }
    });

    // Forward playback events so audio_repository_impl can build PlayerStatus.
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 3],
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: _currentHardwareIndex,
        ),
      );
    });
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  /// Loads the track at [index] into the native player and starts playback.
  Future<void> _loadTrackAtIndex(int index, {bool autoPlay = true}) async {
    if (index < 0 || index >= _currentQueue.length) return;

    _currentHardwareIndex = index;
    final track = _currentQueue[index];

    // Notify listeners immediately so the UI updates the track card.
    _indexController.add(index);
    mediaItem.add(
      MediaItem(
        id: track.id,
        title: track.title,
        artist: track.artist,
        duration: track.duration,
        artUri: _resolveArtworkUri(track.artworkUrl),
        displayDescription: track.description,
        genre: track.genre,
        extras: {
          'artists': track.artists,
          'waveform': track.waveformData,
        },
      ),
    );

    final String rawUrl = (track.streamUrl ?? track.audioUrl).trim();

    AudioSource source;
    if (rawUrl.isEmpty) {
      // Placeholder — no audio yet; load the silent asset so the player
      // doesn't crash but don't auto-play it.
      source = AudioSource.asset('assets/audio/empty.mp3', tag: track.id);
      autoPlay = false;
    } else if (rawUrl.startsWith('assets/')) {
      source = AudioSource.asset(rawUrl, tag: track.id);
    } else {
      final uri = _resolveTrackUri(rawUrl);
      if (uri == null) {
        source = AudioSource.asset('assets/audio/empty.mp3', tag: track.id);
        autoPlay = false;
      } else {
        source = AudioSource.uri(uri, tag: track.id);
      }
    }

    try {
      await _player.setAudioSource(source);
      if (autoPlay) _player.play();
    } catch (e) {
      debugPrint('[RythmifyAudioHandler] _loadTrackAtIndex error: $e');
    }
  }

  // ── Public API (called by AudioRepositoryImpl) ────────────────────────────

  /// Loads a new queue and starts playback from [initialIndex].
  Future<void> loadQueue(
    List<Track> tracks, {
    int initialIndex = 0,
    Duration initialPosition = Duration.zero,
  }) async {
    _currentQueue = List.from(tracks);

    try {
      await _loadTrackAtIndex(initialIndex, autoPlay: false);
      if (initialPosition > Duration.zero) {
        await _player.seek(initialPosition);
      }
      _player.play();
    } catch (e) {
      debugPrint('[RythmifyAudioHandler] loadQueue error: $e');
    }
  }

  /// Updates metadata for a track that was previously a skeleton/placeholder.
  Future<void> updateTrackInfo(String id, Track updatedTrack) async {
    final index = _currentQueue.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final wasPlaceholder =
        (_currentQueue[index].streamUrl ?? _currentQueue[index].audioUrl)
            .trim()
            .isEmpty;

    _currentQueue[index] = updatedTrack;

    if (index == _currentHardwareIndex) {
      // Update the system media item so lock-screen / notification is fresh.
      mediaItem.add(
        MediaItem(
          id: updatedTrack.id,
          title: updatedTrack.title,
          artist: updatedTrack.artist,
          duration: updatedTrack.duration,
          artUri: _resolveArtworkUri(updatedTrack.artworkUrl),
          displayDescription: updatedTrack.description,
          genre: updatedTrack.genre,
          extras: {
            'artists': updatedTrack.artists,
            'waveform': updatedTrack.waveformData,
          },
        ),
      );

      // If the placeholder now has a real URL, hot-swap the audio source.
      final newUrl =
          (updatedTrack.streamUrl ?? updatedTrack.audioUrl).trim();
      if (wasPlaceholder && newUrl.isNotEmpty) {
        final wasPlaying = _player.playing;
        final position = _player.position;
        await _loadTrackAtIndex(index, autoPlay: false);
        if (position > Duration.zero) await _player.seek(position);
        if (wasPlaying) _player.play();
      }
    }
  }

  /// Jumps to [index] in the Dart queue and loads that track.
  Future<void> skipToIndex(int index) async {
    if (index < 0 || index >= _currentQueue.length) return;
    try {
      await _loadTrackAtIndex(index);
    } catch (e) {
      debugPrint('[RythmifyAudioHandler] skipToIndex error: $e');
    }
  }

  /// Reorders the Dart queue without touching the native player.
  Future<void> moveTrack(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;
    if (oldIndex < 0 || oldIndex >= _currentQueue.length) return;
    if (newIndex < 0 || newIndex >= _currentQueue.length) return;

    final track = _currentQueue.removeAt(oldIndex);
    _currentQueue.insert(newIndex, track);

    // Keep the hardware index pointing at the same logical track.
    if (_currentHardwareIndex == oldIndex) {
      _currentHardwareIndex = newIndex;
    } else if (oldIndex < _currentHardwareIndex &&
        newIndex >= _currentHardwareIndex) {
      _currentHardwareIndex--;
    } else if (oldIndex > _currentHardwareIndex &&
        newIndex <= _currentHardwareIndex) {
      _currentHardwareIndex++;
    }
  }

  /// Appends tracks to the Dart queue.
  /// If playback had already completed, auto-advances into the new tracks.
  Future<void> appendTracks(List<Track> tracks) async {
    _currentQueue.addAll(tracks);
    if (_player.processingState == ProcessingState.completed) {
      await skipToIndex(_currentHardwareIndex + 1);
    }
  }

  // ── Streams & getters ─────────────────────────────────────────────────────

  Stream<PlaybackEvent> get playbackEventStream =>
      _player.playbackEventStream;

  Stream<Duration> get positionStream => _player.positionStream;

  /// Emits whenever the active track index changes.
  Stream<int?> get currentIndexStream => _indexController.stream;

  Stream<bool> get playingStream => _player.playingStream;

  bool get playing => _player.playing;

  ProcessingState get processingState => _player.processingState;

  List<Track> get currentQueue => _currentQueue;

  // ── BaseAudioHandler overrides ────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    final next = _currentHardwareIndex + 1;
    if (next < _currentQueue.length) {
      await _loadTrackAtIndex(next);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final prev = _currentHardwareIndex - 1;
    if (prev >= 0) {
      await _loadTrackAtIndex(prev);
    }
  }
}

// ── Top-level helpers ─────────────────────────────────────────────────────

Uri? _resolveTrackUri(String rawUrl) {
  if (rawUrl.isEmpty) return null;

  final parsed = Uri.tryParse(rawUrl);
  if (parsed != null &&
      parsed.hasScheme &&
      (parsed.scheme == 'http' || parsed.scheme == 'https')) {
    return parsed;
  }

  final base = Uri.parse(ApiClient.baseUrl);
  final origin = Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
  );
  final resolved = origin.resolve(rawUrl);
  if (resolved.scheme == 'http' || resolved.scheme == 'https') {
    return resolved;
  }

  return null;
}

Uri? _resolveArtworkUri(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return null;

  final parsed = Uri.tryParse(trimmed);
  if (parsed != null &&
      parsed.hasScheme &&
      (parsed.scheme == 'http' || parsed.scheme == 'https')) {
    return parsed;
  }
  return null;
}
