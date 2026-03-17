import '../../../../core/domain/entities/track.dart';
import '../entities/player_state.dart';

abstract class AudioRepository {
  // Streams for the UI to listen to
  Stream<AppPlayerState> get playerStateStream;
  Stream<List<Track>> get queueStream;

  // Getters for immediate state
  AppPlayerState get currentState;
  List<Track> get currentQueue;

  Future<void> init();
  Future<void> loadQueue(List<Track> tracks, {int initialIndex = 0});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> skipToNext();
  Future<void> skipToPrevious();
  Future<void> setShuffleMode(bool enabled);
  Future<void> setLoopMode(String mode);
}
