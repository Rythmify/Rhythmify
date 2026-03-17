import '../../../../core/domain/entities/track.dart';
import '../repositories/track_repository.dart';

class GetTrackSummary {
  final TrackRepository repository;

  GetTrackSummary(this.repository);

  Future<Track> call(String id) async {
    if (id.isEmpty) throw ArgumentError('Track ID cannot be empty');
    return await repository.getTrackSummary(id);
  }
}