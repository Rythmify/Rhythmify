import '../repositories/track_repository.dart';

/// [UpdateTrack] is a use case for updating track metadata.
class UpdateTrack {
  final TrackRepository repository;

  UpdateTrack(this.repository);

  /// Updates the track with the given [id] using the provided [data].
  Future<void> call(String id, Map<String, dynamic> data) async {
    if (id.isEmpty) return;
    await repository.updateTrack(id, data);
  }
}
