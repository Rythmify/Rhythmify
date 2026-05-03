import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/track.dart';

/// Represents the current playback status of the audio player.
enum PlayerStatus {
  /// Initial state before any track is loaded.
  initial,

  /// Audio is being buffered or loaded.
  loading,

  /// Audio is currently playing.
  playing,

  /// Audio is paused.
  paused,

  /// Playback has stopped or finished.
  stopped,

  /// An error occurred during playback.
  error,
}

/// Represents the global state of the audio player, including current track,
/// playback position, duration, and playback modes.
///
/// This entity is used across the [Domain] and [Presentation] layers to
/// represent the UI state of the player.
class AppPlayerState extends Equatable {
  /// The current status of the player.
  final PlayerStatus status;

  /// The currently active track, if any.
  final Track? currentTrack;

  /// The current playback position.
  final Duration position;

  /// The current buffered position.
  final Duration bufferedPosition;

  /// The total duration of the current track.
  final Duration duration;

  /// Whether shuffle mode is currently active.
  final bool isShuffleModeEnabled;

  /// The current loop mode (e.g., 'off', 'all', 'one').
  final String loopMode;

  /// The current index of the track in the native hardware queue.
  final int? queueIndex;

  const AppPlayerState({
    this.status = PlayerStatus.initial,
    this.currentTrack,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffleModeEnabled = false,
    this.loopMode = 'off',
    this.queueIndex,
  });

  /// Returns a copy of the current state with the given fields replaced.
  AppPlayerState copyWith({
    PlayerStatus? status,
    Track? currentTrack,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    bool? isShuffleModeEnabled,
    String? loopMode,
    int? queueIndex,
  }) {
    return AppPlayerState(
      status: status ?? this.status,
      currentTrack: currentTrack ?? this.currentTrack,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
      isShuffleModeEnabled: isShuffleModeEnabled ?? this.isShuffleModeEnabled,
      loopMode: loopMode ?? this.loopMode,
      queueIndex: queueIndex ?? this.queueIndex,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentTrack,
    position,
    bufferedPosition,
    duration,
    isShuffleModeEnabled,
    loopMode,
    queueIndex,
  ];
}
