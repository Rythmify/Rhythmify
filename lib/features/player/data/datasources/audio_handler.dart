import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/domain/entities/track.dart';

class RythmifyAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  
  List<Track> _currentQueue = [];

  RythmifyAudioHandler() { _init(); }

  Future<void> _init() async {

    /// Broadcast player state changes to the OS
    /// Ex: Lock screen, Bluetooth cars, etc.
  
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls:
        [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const
        {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const
        {
          ProcessingState.idle:      AudioProcessingState.idle,
          ProcessingState.loading:   AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready:     AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,

        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });

    /// Listen to current index changes
    /// To update lock screen media item

    _player.currentIndexStream.listen((index)
    {
      if (index != null && index < _currentQueue.length)
      {
        final track = _currentQueue[index];
        mediaItem.add(MediaItem(
          id: track.id,
          title: track.title,
          artist: track.artist,
          duration: track.duration,
          artUri: Uri.parse('asset:///${track.artworkUrl}'),
        ));
      }
    });
  }

  Future<void> updateTrackInfo(String id, Track updatedTrack) async {
    final index = _currentQueue.indexWhere((t) => t.id == id);
    if (index != -1) {
      _currentQueue[index] = updatedTrack;
      
      // If it's the currently playing track, update mediaItem to reflect new metadata
      if (_player.currentIndex == index) {
        mediaItem.add(MediaItem(
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
        ));
      }
    }
  }

  // --- API for the Repository to use ---
  Stream<PlaybackEvent> get playbackEventStream => _player.playbackEventStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<bool> get playingStream => _player.playingStream;
  bool get playing => _player.playing;
  ProcessingState get processingState => _player.processingState;
  List<Track> get currentQueue => _currentQueue;

  Future<void> loadQueue(List<Track> tracks, {int initialIndex = 0}) async {
    _currentQueue = tracks;
    
    final audioSources = tracks.map((track) {
      final url = track.audioUrl;
      if (url.startsWith('assets/'))  //change later
      {
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

  // --- The actual actions ---
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
