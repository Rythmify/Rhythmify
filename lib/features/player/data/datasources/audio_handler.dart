import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/domain/entities/track_summary.dart';

class RythmifyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  List<TrackSummary> _currentQueue = [];

  RythmifyAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // Load empty playlist
    await _player.setAudioSource(_playlist);

    // Broadcast player state changes
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
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
      ));
    });

    // Listen to current index changes to update mediaItem
    _player.currentIndexStream.listen((index) {
      if (index != null && index < _currentQueue.length) {
        final track = _currentQueue[index];
        mediaItem.add(MediaItem(
          id: track.id,
          title: track.title,
          artist: track.artist,
          duration: track.duration,
          artUri: Uri.parse('asset:///${track.artworkUrl}'), // Assuming local assets for now
        ));
      }
    });
  }

  // --- External API ---

  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<double> get volumeStream => _player.volumeStream;
  Stream<double> get speedStream => _player.speedStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<bool> get playingStream => _player.playingStream;

  List<TrackSummary> get currentQueue => _currentQueue;

  Future<void> loadQueue(List<TrackSummary> tracks, {int initialIndex = 0}) async {
    _currentQueue = tracks;
    
    final audioSources = tracks.map((track) {
      // In a real app, this would be a network URL. 
      // Based on the mock, it might be an asset or string.
      // We will try to load it as an asset if it contains 'assets/'
      final url = track.audioUrl;
      if (url.startsWith('assets/')) {
        return AudioSource.asset(url, tag: track.id);
      } else {
        return AudioSource.uri(Uri.parse(url), tag: track.id);
      }
    }).toList();

    await _playlist.clear();
    await _playlist.addAll(audioSources);
    
    // Update audio service queue
    final mediaItems = tracks.map((t) => MediaItem(
      id: t.id,
      title: t.title,
      artist: t.artist,
      duration: t.duration,
      artUri: Uri.parse('asset:///${t.artworkUrl}')
    )).toList();
    queue.add(mediaItems);

    await _player.seek(Duration.zero, index: initialIndex);
  }

  // --- BaseAudioHandler Overrides ---

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

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }
}
