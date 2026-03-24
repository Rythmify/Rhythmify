import '../../../../core/domain/entities/track.dart';
import '../repositories/track_repository.dart';

/// [GetTrackDetails] is a use case responsible for fetching a single track's full details.
///
/// It ensures that a valid track ID is provided before querying the [TrackRepository].
class GetTrackDetails {
  final TrackRepository repository;

  GetTrackDetails(this.repository);

  /// Retrieves a specific [Track] by its ID.
  ///
  /// Throws an [ArgumentError] if the provided [id] is empty.
  Future<Track> call(String id) async {
    if (id.isEmpty) throw ArgumentError('Track ID cannot be empty');
    return await repository.getTrackDetails(id);
  }
}
