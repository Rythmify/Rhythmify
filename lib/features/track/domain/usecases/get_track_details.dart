import '../../../../core/domain/entities/track.dart';
import '../repositories/track_repository.dart';

class GetTrackDetails {
  final TrackRepository repository;

  GetTrackDetails(this.repository);

  Future<Track> call(String id) async {
    if (id.isEmpty) throw ArgumentError('Track ID cannot be empty');
    return await repository.getTrackDetails(id);
  }
}