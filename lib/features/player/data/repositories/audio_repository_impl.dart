import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/domain/entities/track_summary.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_handler.dart';

class AudioRepositoryImpl implements AudioRepository {
  final RythmifyAudioHandler _audioHandler;

  final _playerStateController = StreamController<AppPlayerState>.broadcast();
  final _queueController = StreamController<List<TrackSummary>>.broadcast();

  AppPlayerState _currentState = const AppPlayerState();

  AudioRepositoryImpl(this._audioHandler) {
    _initStreams();
  }

  void _initStreams() {
    // Combine various streams from audio handler into a single AppPlayerState
    
    _audioHandler.playbackEventStream.listen((event) {
      final status = _mapProcessingState(event.processingState, _audioHandler.playbackState.value.playing);
      _updateState(_currentState.copyWith(
        status: status,
        bufferedPosition: event.bufferedPosition,
        duration: event.duration ?? Duration.zero,
      ));
    });

    _audioHandler.positionStream.listen((position) {
      _updateState(_currentState.copyWith(position: position));
    });

    _audioHandler.currentIndexStream.listen((index) {
      if (index != null && index < _audioHandler.currentQueue.length) {
        _updateState(_currentState.copyWith(
          currentTrack: _audioHandler.currentQueue[index],
        ));
      }
    });

    _audioHandler.playingStream.listen((playing) {
      final currentProcessing = _audioHandler.playbackState.value.processingState;
      final status = _mapAudioServiceState(currentProcessing, playing);
      _updateState(_currentState.copyWith(status: status));
    });

    // Initialize with current queue if any
    _queueController.add(_audioHandler.currentQueue);
  }

  void _updateState(AppPlayerState newState) {
    _currentState = newState;
    _playerStateController.add(_currentState);
  }

  PlayerStatus _mapProcessingState(ProcessingState state, bool playing) {
    switch (state) {
      case ProcessingState.idle:
        return PlayerStatus.initial;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return PlayerStatus.loading;
      case ProcessingState.ready:
        return playing ? PlayerStatus.playing : PlayerStatus.paused;
      case ProcessingState.completed:
        return PlayerStatus.stopped;
    }
  }

  PlayerStatus _mapAudioServiceState(AudioProcessingState state, bool playing) {
    switch (state) {
      case AudioProcessingState.idle:
        return PlayerStatus.initial;
      case AudioProcessingState.loading:
      case AudioProcessingState.buffering:
        return PlayerStatus.loading;
      case AudioProcessingState.ready:
        return playing ? PlayerStatus.playing : PlayerStatus.paused;
      case AudioProcessingState.completed:
        return PlayerStatus.stopped;
      case AudioProcessingState.error:
        return PlayerStatus.error;
    }
  }

  @override
  Stream<AppPlayerState> get playerStateStream => _playerStateController.stream;

  @override
  Stream<List<TrackSummary>> get queueStream => _queueController.stream;

  @override
  AppPlayerState get currentState => _currentState;

  @override
  List<TrackSummary> get currentQueue => _audioHandler.currentQueue;

  @override
  Future<void> init() async {
    // Initialization is mostly handled by constructor
  }

  @override
  Future<void> loadQueue(List<TrackSummary> tracks, {int initialIndex = 0}) async {
    _updateState(_currentState.copyWith(status: PlayerStatus.loading));
    await _audioHandler.loadQueue(tracks, initialIndex: initialIndex);
    _queueController.add(tracks);
  }

  @override
  Future<void> play() => _audioHandler.play();

  @override
  Future<void> pause() => _audioHandler.pause();

  @override
  Future<void> seek(Duration position) => _audioHandler.seek(position);

  @override
  Future<void> skipToNext() => _audioHandler.skipToNext();

  @override
  Future<void> skipToPrevious() => _audioHandler.skipToPrevious();

  @override
  Future<void> setShuffleMode(bool enabled) async {
    // To be implemented fully with just_audio's setShuffleModeEnabled
    _updateState(_currentState.copyWith(isShuffleModeEnabled: enabled));
  }

  @override
  Future<void> setLoopMode(String mode) async {
    // To be implemented fully with just_audio's setLoopMode
    _updateState(_currentState.copyWith(loopMode: mode));
  }
}
