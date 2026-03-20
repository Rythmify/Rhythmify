import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';

class GetTrendingTracks {
  final HomeRepository repository;

  GetTrendingTracks(this.repository);

  Future<List<Track>> call(String genre) {
    return repository.getTrendingTracks(genre);
  }
}
