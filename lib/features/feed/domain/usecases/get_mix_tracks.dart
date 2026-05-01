import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';

/// Use case for getting mixed tracks
class GetMixTracks {
  final HomeRepository _repo;
  GetMixTracks(this._repo);

  /// Executes the use case, returning a list of mix tracks
  Future<List<Track>> call(String mixId) => _repo.getMixTracks(mixId);
}
