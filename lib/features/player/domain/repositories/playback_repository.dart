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
}
