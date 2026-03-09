import '../../../../core/domain/entities/track.dart';
import '../repositories/track_repository.dart';

class SearchTracks {
  final TrackRepository repository;

  SearchTracks(this.repository);

  Future<List<Track>> call(String query) async {
    if (query.trim().isEmpty) return [];
    return await repository.searchTracks(query);
  }
}