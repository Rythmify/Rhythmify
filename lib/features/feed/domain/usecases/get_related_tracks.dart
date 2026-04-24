import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';

class GetRelatedTracks {
  final HomeRepository _repo;
  GetRelatedTracks(this._repo);
  Future<List<Track>> call(String trackId) => _repo.getRelatedTracks(trackId);
}
