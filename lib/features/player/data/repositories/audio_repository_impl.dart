import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/player_state.dart';
import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_handler.dart';

/// Concrete implementation of [AudioRepository] using [RythmifyAudioHandler].
///
/// This implementation manages the synchronization between the [AudioPlayer]
/// events and the domain-level [AppPlayerState].
class AudioRepositoryImpl implements AudioRepository {
  /// The underlying audio handler responsible for playback.
  final RythmifyAudioHandler _audioHandler;

  /// Broadcast controller for publishing player state updates.
  final _playerStateController = StreamController<AppPlayerState>.broadcast();

  /// Broadcast controller for publishing queue updates.
  final _queueController = StreamController<List<Track>>.broadcast();

  /// Internal cache of the current state.
  AppPlayerState _currentState = const AppPlayerState();

  AudioRepositoryImpl(this._audioHandler) {
    _initStreams();
  }

  /// Sets up listeners to internal [AudioPlayer] streams and maps them to
  /// domain-friendly [AppPlayerState] updates.
  void _initStreams() {
    _audioHandler.playbackEventStream.listen((event) {
      _updatePlayerStatusAndPosition(
        processingState: event.processingState,
        playing: _audioHandler.playing,
        bufferedPosition: event.bufferedPosition,
        duration: event.duration,
      );
    });

    _audioHandler.positionStream.listen((position) {
      _updateState(_currentState.copyWith(position: position));
    });

    _audioHandler.currentIndexStream.listen((index) {
      if (index != null && index < _audioHandler.currentQueue.length) {
        _updateState(
          _currentState.copyWith(
            currentTrack: _audioHandler.currentQueue[index],
          ),
        );
      }
    });

    _audioHandler.playingStream.listen((playing) {
      _updatePlayerStatusAndPosition(
        processingState: _audioHandler.processingState,
        playing: playing,
      );
    });

    _queueController.add(_audioHandler.currentQueue);
  }

  /// Updates the local [_currentState] and notifies all listeners via [_playerStateController].
  void _updateState(AppPlayerState newState) {
    _currentState = newState;
    _playerStateController.add(_currentState);
  }

  /// Calculates the new [PlayerStatus] and updates the state.
  void _updatePlayerStatusAndPosition({
    ProcessingState? processingState,
    bool? playing,
    Duration? bufferedPosition,
    Duration? duration,
  }) {
    final status = _calculateStatus(
      processingState ?? _audioHandler.processingState,
      playing ?? _audioHandler.playing,
    );

    _updateState(
      _currentState.copyWith(
        status: status,
        bufferedPosition: bufferedPosition ?? _currentState.bufferedPosition,
        duration: duration ?? _currentState.duration,
      ),
    );
  }

  /// Maps [just_audio]'s [ProcessingState] to domain [PlayerStatus].
  PlayerStatus _calculateStatus(ProcessingState state, bool isPlaying) {
    switch (state) {
      case ProcessingState.idle:
        return PlayerStatus.initial;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return PlayerStatus.loading;
      case ProcessingState.ready:
        return isPlaying ? PlayerStatus.playing : PlayerStatus.paused;
      case ProcessingState.completed:
        return PlayerStatus.stopped;
    }
  }

  @override
  Stream<AppPlayerState> get playerStateStream => _playerStateController.stream;

  @override
  Stream<List<Track>> get queueStream => _queueController.stream;

  @override
  AppPlayerState get currentState => _currentState;

  @override
  List<Track> get currentQueue => _audioHandler.currentQueue;

  @override
  Future<void> init() async {}

  @override
  Future<void> loadQueue(List<Track> tracks, {int initialIndex = 0}) async {
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
    _updateState(_currentState.copyWith(isShuffleModeEnabled: enabled));
  }

  @override
  Future<void> setLoopMode(String mode) async {
    _updateState(_currentState.copyWith(loopMode: mode));
  }

  @override
  Future<void> updateTrackInfo(String id, Track updatedTrack) async {
    await _audioHandler.updateTrackInfo(id, updatedTrack);

    if (_currentState.currentTrack?.id == id) {
      _updateState(_currentState.copyWith(currentTrack: updatedTrack));
    }

    _queueController.add(_audioHandler.currentQueue);
  }
}
