import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';

class GetHotTracks {
  final HomeRepository repository;

  GetHotTracks(this.repository);

  Future<List<Track>> call() {
    return repository.getHotTracks();
  }
}
