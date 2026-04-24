import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';

class GetMixTracks {
  final HomeRepository _repo;
  GetMixTracks(this._repo);
  Future<List<Track>> call(String mixId) => _repo.getMixTracks(mixId);
}
