import '../repositories/track_repository.dart';

/// [ToggleRepost] is a mutation use case used to manage the 'repost' status of a track.
///
/// It coordinates with [TrackRepository] to notify the system of the change in
/// repost status for the track with [id].

class ToggleRepost {
  final TrackRepository repository;

  ToggleRepost(this.repository);

  /// Toggles the 'repost' state of the track with the given [id].
  ///
  /// [isCurrentlyReposted] represents the current status, and this call
  /// will trigger a request to set it to the opposite status.

  Future<void> call(String id, bool isCurrentlyReposted) async {
    if (id.isEmpty) return;
    await repository.toggleRepost(id, !isCurrentlyReposted);
  }
}
