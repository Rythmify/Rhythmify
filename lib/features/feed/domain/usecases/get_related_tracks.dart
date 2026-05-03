import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';

/// Use case for getting related tracks
class GetRelatedTracks {
  final HomeRepository _repo;
  GetRelatedTracks(this._repo);

  /// Executes the use case, returning a list of related tracks
  Future<List<Track>> call(String trackId) => _repo.getRelatedTracks(trackId);
}
