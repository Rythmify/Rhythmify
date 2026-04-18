import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/domain/entities/track.dart';

/// A custom [BaseAudioHandler] implementation using [just_audio] to manage
/// background playback and system media controls.
///
/// This handler bridges the application's playback logic with the operating
/// system's media session, enabling lock screen controls, notifications, and
/// hardware button support.
class RythmifyAudioHandler extends BaseAudioHandler with SeekHandler {
  /// The underlying audio player instance.
  final AudioPlayer _player = AudioPlayer(
    audioLoadConfiguration: const AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: Duration(seconds: 30),               // Buffer 30 seconds ahead
        maxBufferDuration: Duration(seconds: 120),              // Up to 2 minutes
        bufferForPlaybackDuration: Duration(milliseconds: 500), // Start playing fast
        bufferForPlaybackAfterRebufferDuration: Duration(seconds: 1),
      ),
      darwinLoadControl: DarwinLoadControl(
        automaticallyWaitsToMinimizeStalling: true,             // For iOS seamless playback
      ),
    ),
  );

  /// The current list of tracks in the playback queue.
  List<Track> _currentQueue = [];

  RythmifyAudioHandler() {
    _init();
  }

  /// Initializes listeners for playback events and current index changes to
  /// sync the [playbackState] and [mediaItem] with the system.
  Future<void> _init() async {
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
          queueIndex: event.currentIndex,
        ),
      );
    });

    _player.currentIndexStream.listen((index) {
      if (index != null && index < _currentQueue.length) {
        final track = _currentQueue[index];
        mediaItem.add(
          MediaItem(
            id: track.id,
            title: track.title,
            artist: track.artist,
            duration: track.duration,
            artUri: _resolveArtworkUri(track.artworkUrl),
          ),
        );
      }
    });
  }

  /// Updates the metadata for a specific track in the queue.
  ///
  /// If the updated track is the one currently playing, it also updates the
  /// system's [mediaItem].
  Future<void> updateTrackInfo(String id, Track updatedTrack) async {
    final index = _currentQueue.indexWhere((t) => t.id == id);
    if (index != -1) {
      _currentQueue[index] = updatedTrack;

      if (_player.currentIndex == index) {
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
      }
    }
  }

  /// Exposes the playback event stream from [AudioPlayer].
  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;

  /// Exposes the current position stream from [AudioPlayer].
  Stream<Duration> get positionStream => _player.positionStream;

  /// Exposes the current index stream from [AudioPlayer].
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  /// Exposes the playing status stream from [AudioPlayer].
  Stream<bool> get playingStream => _player.playingStream;

  /// Returns whether audio is currently playing.
  bool get playing => _player.playing;

  /// Returns the current [ProcessingState] of the player.
  ProcessingState get processingState => _player.processingState;

  /// Returns the current local queue of tracks.
  List<Track> get currentQueue => _currentQueue;

  /// Loads a new set of [Track]s into the player and prepares for playback.
  /// Loads a new set of [Track]s into the player and prepares for playback.
  Future<void> loadQueue(List<Track> tracks, {int initialIndex = 0}) async {
    _currentQueue = tracks;

    final List<AudioSource> audioSources = [];

    for (final track in tracks) {
      final String rawUrl = (track.streamUrl ?? track.audioUrl).trim();

      if (rawUrl.isEmpty) {
        // Skip invalid tracks to prevent crash
        continue;
      }

      if (rawUrl.startsWith('assets/')) {
        audioSources.add(AudioSource.asset(rawUrl, tag: track.id));
      } else {
        final resolvedUri = _resolveTrackUri(rawUrl);
        if (resolvedUri != null) {
          // ignore: experimental_member_use
          audioSources.add(LockCachingAudioSource(resolvedUri, tag: track.id));
        }
      }
    }

    if (audioSources.isEmpty) {
      return;
    }

    // Ensure initialIndex is within bounds after potentially skipping tracks
    final effectiveIndex = initialIndex < audioSources.length ? initialIndex: 0;

    await _player.setAudioSources(
      audioSources,
      initialIndex: effectiveIndex,
      initialPosition: Duration.zero,
    );
  }

  /// Clears the cached audio files from device storage to free up space.
  /// Call this from your app's settings menu or on startup if cache size gets too large.
  
  // Future<void> clearAudioCache() async {
  //   await LockCachingAudioSource.clearCache();
  // }

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> skipToNext() => _player.seekToNext();
  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();
}

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

  // Avoid invalid asset/network URI values in system media metadata.
  return null;
}