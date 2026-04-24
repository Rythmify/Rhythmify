class FanLeaderboardItem {
  final int rank;
  final String userId;
  final String username;
  final String displayName;
  final String? profilePicture;
  final bool isVerified;
  final int playCount;
  final DateTime lastPlayedAt;

  const FanLeaderboardItem({
    required this.rank,
    required this.userId,
    required this.username,
    required this.displayName,
    this.profilePicture,
    required this.isVerified,
    required this.playCount,
    required this.lastPlayedAt,
  });
}
