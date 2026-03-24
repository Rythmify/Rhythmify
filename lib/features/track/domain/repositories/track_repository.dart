import '../../../../core/domain/entities/track.dart';

/// [TrackRepository] defines the contract for track-related data operations.
///
/// This repository is responsible for abstracting the data sources (Remote/Local)
/// and providing a unified interface for the domain layer to interact with
/// track data and perform business mutations.
abstract class TrackRepository {
  //=========================
  //   --- Fetching Data ---
  //=========================

  /// Fetches detailed information for a specific [Track] by its unique identifier.
  ///
  /// Includes metadata such as waveform data, descriptions, and artist details.
  Future<Track> getTrackDetails(String id);

  /// Fetches a list of all available [Track] entities.
  ///
  /// Used for populating feed and library views.
  Future<List<Track>> getTracks();

  /// Retrieves the waveform peak data for a specific track.
  ///
  /// Returns a list of doubles representing the amplitude peaks used for
  /// rendering the audio waveform visualizer.
  Future<List<double>> getWaveform(String trackId);

  /// Fetches all available music tags/genres.
  ///
  /// Returns a mapping of unique tag IDs to their display names.
  Future<Map<String, String>> getTags();

  //=========================
  //   --- Mutations ---
  //=========================

  /// Toggles the user's 'like' status for a specific track.
  ///
  /// [id] The unique identifier of the track.
  /// [isCurrentlyLiked] The current state to be toggled.
  Future<void> toggleLike(String id, bool isCurrentlyLiked);

  /// Toggles the user's 'repost' status for a specific track.
  ///
  /// [id] The unique identifier of the track.
  /// [isCurrentlyReposted] The current state to be toggled.
  Future<void> toggleRepost(String id, bool isCurrentlyReposted);

  /// Records a play event for the specified track.
  ///
  /// This triggers an increment in the track's play count on the backend.
  Future<void> recordPlay(String id);
}
