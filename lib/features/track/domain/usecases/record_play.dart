import '../repositories/track_repository.dart';

/// [RecordPlay] is a mutation use case that tracks when a track is played.
///
/// It notifies the [TrackRepository] to increment the play count for the track.

class RecordPlay {
  final TrackRepository repository;

  RecordPlay(this.repository);

  /// Records a play session for the specified track [id].
  Future<void> call(String id) async {
    if (id.isEmpty) return;
    await repository.recordPlay(id);
  }
}
