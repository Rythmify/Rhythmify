import '../repositories/track_repository.dart';

/// [DeleteTrack] is a use case for deleting a track.
class DeleteTrack {
  final TrackRepository repository;

  DeleteTrack(this.repository);

  /// Deletes the track with the given [id].
  Future<void> call(String id) async {
    if (id.isEmpty) return;
    await repository.deleteTrack(id);
  }
}
