import '../../../../core/domain/entities/track_summary.dart';
import '../entities/player_state.dart';

abstract class AudioRepository {
  // Streams for the UI to listen to
  Stream<AppPlayerState> get playerStateStream;
  Stream<List<TrackSummary>> get queueStream;

  // Getters for immediate state
  AppPlayerState get currentState;
  List<TrackSummary> get currentQueue;

  Future<void> init();
  Future<void> loadQueue(List<TrackSummary> tracks, {int initialIndex = 0});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> skipToNext();
  Future<void> skipToPrevious();
  Future<void> setShuffleMode(bool enabled);
  Future<void> setLoopMode(String mode);
}