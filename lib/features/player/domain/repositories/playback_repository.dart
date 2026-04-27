import '../entities/history_record.dart';

abstract class PlaybackRepository {
  /// Initiates playback for a track and returns the stream/preview URL.
  /// Increments the global play count on the backend.
  Future<String> initiatePlayback(String trackId);

  /// Records a listening history event.
  /// Handles offline caching if the network is unavailable.
  Future<void> recordListeningHistory(HistoryRecord record);

  /// Synchronizes any pending offline history records with the backend.
  Future<void> syncPendingHistory();

  /// Fetches the resolved queue context from the backend.
  /// Used for "play" and "next_up" interactions.
  Future<Map<String, dynamic>> fetchQueueContext({
    required String interactionType,
    required String sourceType,
    String? sourceId,
    String? targetUserId,
  });

  /// Synchronizes the current player state (current track and remaining queue) to the backend.
  Future<void> syncPlayerState({
    required String trackId,
    required List<Map<String, dynamic>> queue,
    int positionSeconds = 0,
    double volume = 0.5,
  });
}
