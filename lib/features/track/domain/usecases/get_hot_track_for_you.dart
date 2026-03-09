import '../../../../core/domain/entities/track.dart';
import '../repositories/track_repository.dart';

class GetHotTrackForYou {
  final TrackRepository repository;

  GetHotTrackForYou(this.repository);

  Future<Track> call() async {
    return await repository.getHotTrackForYou();
  }
}