import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/track_summary.dart';

enum PlayerStatus { initial, loading, playing, paused, stopped, error }

class AppPlayerState extends Equatable {
  final PlayerStatus status;
  final TrackSummary? currentTrack;
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final bool isShuffleModeEnabled;
  final String loopMode;    /// 'off', 'all', 'one'

  const AppPlayerState({
    this.status = PlayerStatus.initial,
    this.currentTrack,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffleModeEnabled = false,
    this.loopMode = 'off',
  });

  AppPlayerState copyWith({
    PlayerStatus? status,
    TrackSummary? currentTrack,
    Duration? position,
    Duration? bufferedPosition,
    Duration? duration,
    bool? isShuffleModeEnabled,
    String? loopMode,
  }) {
    return AppPlayerState(
      status: status ?? this.status,
      currentTrack: currentTrack ?? this.currentTrack,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      duration: duration ?? this.duration,
      isShuffleModeEnabled: isShuffleModeEnabled ?? this.isShuffleModeEnabled,
      loopMode: loopMode ?? this.loopMode,
    );
  }

/// If the variables inside this list match,
/// consider the whole object identical
  @override
  List<Object?> get props =>
  [
    status,
    currentTrack,
    position,
    bufferedPosition,
    duration,
    isShuffleModeEnabled,
    loopMode,
  ];
}