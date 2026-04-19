import '../../domain/entities/fan_leaderboard.dart';
import '../../domain/entities/fan_leaderboard_item.dart';

class FanLeaderboardDto {
  static FanLeaderboard fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>)
        .map((item) => FanLeaderboardItemDto.fromJson(item as Map<String, dynamic>))
        .toList();

    return FanLeaderboard(
      period: data['period'] as String,
      items: items,
    );
  }
}

class FanLeaderboardItemDto {
  static FanLeaderboardItem fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;

    return FanLeaderboardItem(
      rank: json['rank'] as int,
      userId: user['id'] as String,
      username: user['username'] as String,
      displayName: user['display_name'] as String,
      profilePicture: user['profile_picture'] as String?,
      isVerified: user['is_verified'] as bool? ?? false,
      playCount: json['play_count'] as int,
      lastPlayedAt: DateTime.parse(json['last_played_at'] as String),
    );
  }
}
