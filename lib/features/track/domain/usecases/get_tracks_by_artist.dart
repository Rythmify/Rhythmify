import '../../../../core/domain/entities/track_summary.dart';
import '../repositories/track_repository.dart';

class GetTracksByArtist {
  final TrackRepository repository;

  GetTracksByArtist(this.repository);

  Future<List<TrackSummary>> call(String artistId) async {
    if (artistId.isEmpty) throw ArgumentError('Artist ID cannot be empty');
    return await repository.getTracksByArtist(artistId);
  }
}