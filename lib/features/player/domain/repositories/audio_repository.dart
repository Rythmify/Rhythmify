import '../../../../core/domain/entities/track.dart';
import '../entities/player_state.dart';

/// Interface for audio playback and queue management.
///
/// Implementations of this repository should handle audio engine initialization,
/// playback controls, and maintain the current [AppPlayerState].
abstract class AudioRepository {
  /// Stream providing real-time updates of the player state.
  Stream<AppPlayerState> get playerStateStream;

  /// Stream providing updates to the current playback queue.
  Stream<List<Track>> get queueStream;

  /// Retrieves the current snapshot of the [AppPlayerState].
  AppPlayerState get currentState;

  /// Retrieves the current snapshot of the playback queue.
  List<Track> get currentQueue;

  /// Initializes the audio engine and sets up necessary background handlers.
  Future<void> init();

  /// Loads a list of [Track]s into the playback queue and starts playback from [initialIndex].
  Future<void> loadQueue(List<Track> tracks, {int initialIndex = 0});

  /// Starts or resumes audio playback.
  Future<void> play();

  /// Pauses audio playback.
  Future<void> pause();

  /// Seeks to a specific [position] within the current track.
  Future<void> seek(Duration position);

  /// Skips to the next track in the queue.
  Future<void> skipToNext();

  /// Skips to the previous track or restarts the current track if enough time has passed.
  Future<void> skipToPrevious();

  /// Toggles the shuffle mode of the player.
  Future<void> setShuffleMode(bool enabled);

  /// Sets the loop mode of the player (e.g., 'off', 'all', 'one').
  Future<void> setLoopMode(String mode);

  /// Updates metadata for a track in the current queue using its [id].
  Future<void> updateTrackInfo(String id, Track updatedTrack);
}
