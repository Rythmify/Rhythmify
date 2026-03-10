import '../../../../core/domain/entities/track_summary.dart';
import '../repositories/track_repository.dart';

class GetHotTrackForYou {
  final TrackRepository repository;

  GetHotTrackForYou(this.repository);

  Future<TrackSummary> call() async {
    return await repository.getHotTrackForYou();
  }
}