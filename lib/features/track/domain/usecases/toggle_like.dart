import '../repositories/track_repository.dart';

/// [ToggleLike] is a mutation use case for updating the 'like' status of a track.
///
/// It communicates the change to the [TrackRepository], ensuring the user's
/// preferences are synchronized with the backend or local cache.

class ToggleLike {
  final TrackRepository repository;

  ToggleLike(this.repository);

  /// Toggles the 'like' state of a [Track] specified by [id].
  ///
  /// [isCurrentlyLiked] is the current state of the track, and this call
  /// will trigger a request to set it to the opposite state.
  
  Future<void> call(String id, bool isCurrentlyLiked) async {
    if (id.isEmpty) return;
    await repository.toggleLike(id, !isCurrentlyLiked);
  }
}
