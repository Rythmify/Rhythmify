import '../entities/fan_leaderboard.dart';
import '../repositories/track_repository.dart';

class GetFanLeaderboard {
  final TrackRepository repository;

  GetFanLeaderboard(this.repository);

  Future<FanLeaderboard> call(String trackId, String period) {
    return repository.getFanLeaderboard(trackId, period);
  }
}
