import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/domain/entities/track.dart';

/// A custom [BaseAudioHandler] implementation using [just_audio] to manage
/// background playback and system media controls.
///
/// This handler bridges the application's playback logic with the operating
/// system's media session, enabling lock screen controls, notifications, and
/// hardware button support.
class RythmifyAudioHandler extends BaseAudioHandler with SeekHandler {
  /// The underlying audio player instance.
  final AudioPlayer _player = AudioPlayer();

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
            artUri: Uri.parse('asset:///${track.artworkUrl}'),
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
            artUri: Uri.parse('asset:///${updatedTrack.artworkUrl}'),
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
  Future<void> loadQueue(List<Track> tracks, {int initialIndex = 0}) async {
    _currentQueue = tracks;

    final audioSources = tracks.map((track) {
      final url = track.audioUrl;
      if (url.startsWith('assets/')) {
        return AudioSource.asset(url, tag: track.id);
      } else {
        return AudioSource.uri(Uri.parse(url), tag: track.id);
      }
    }).toList();

    await _player.setAudioSources(
      audioSources,
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );
  }

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
