import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/fan_leaderboard.dart';
import 'track_dependency_providers.dart';

/// Period options for the fan leaderboard.
enum LeaderboardPeriod {
  overall('overall', 'All Time'),
  sevenDays('last_7_days', 'Last 7 Days');

  final String value;
  final String label;
  const LeaderboardPeriod(this.value, this.label);
}

/// Provider to manage the selected period for a specific track's leaderboard.
final fanLeaderboardPeriodProvider = StateProvider.family<LeaderboardPeriod, String>((ref, trackId) {
  return LeaderboardPeriod.overall;
});

/// FutureProvider to fetch fan leaderboard data based on trackId and period.
final fanLeaderboardProvider = FutureProvider.family<FanLeaderboard, String>((ref, trackId) async {
  final period = ref.watch(fanLeaderboardPeriodProvider(trackId));
  final useCase = ref.watch(getFanLeaderboardUseCaseProvider);
  
  return useCase(trackId, period.value);
});
