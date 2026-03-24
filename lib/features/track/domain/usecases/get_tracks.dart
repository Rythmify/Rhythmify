import '../../../../core/domain/entities/track.dart';
import '../repositories/track_repository.dart';

/// [GetTracks] handles the retrieval of multiple track entities.
///
/// It coordinates with [TrackRepository] to provide a collection
/// of tracks for various feed and collection views.
class GetTracks {
  final TrackRepository repository;

  GetTracks(this.repository);

  /// Fetches a list of [Track] objects from the repository.
  Future<List<Track>> call() async {
    return await repository.getTracks();
  }
}
