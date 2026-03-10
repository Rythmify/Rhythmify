import '../../../../core/domain/entities/track_summary.dart';
import '../repositories/track_repository.dart';

class SearchTracks {
  final TrackRepository repository;

  SearchTracks(this.repository);

  Future<List<TrackSummary>> call(String query) async {
    if (query.trim().isEmpty) return [];
    return await repository.searchTracks(query);
  }
}