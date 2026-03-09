import '../../../../core/domain/entities/track.dart';
import '../repositories/track_repository.dart';

class GetTrendingTracks {
  final TrackRepository repository;

  GetTrendingTracks(this.repository);

  Future<List<Track>> call() async {
    return await repository.getTrendingTracks();
  }
}