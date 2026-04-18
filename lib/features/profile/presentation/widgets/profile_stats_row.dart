// coverage:ignore-file
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

/// A horizontal row displaying a user's follower and following counts.
///
/// Numbers are formatted with K/M suffixes for readability:
/// - 1000 → 1.0K
/// - 1500000 → 1.5M
///
/// Used on [PublicProfilePage] below the user's display name.
///
/// Example usage:
/// ```dart
/// ProfileStatsRow(
///   followersCount: 1240,
///   followingCount: 380,
/// )
/// ```
class ProfileStatsRow extends StatelessWidget {
  /// The total number of users following this profile.
  final int followersCount;

  /// The total number of users this profile is following.
  final int followingCount;

  /// Called when followers counter is tapped.
  final VoidCallback? onFollowersTap;

  /// Called when following counter is tapped.
  final VoidCallback? onFollowingTap;

  /// Creates a [ProfileStatsRow].
  const ProfileStatsRow({
    super.key,
    required this.followersCount,
    required this.followingCount,
    this.onFollowersTap,
    this.onFollowingTap,
  });

  /// Formats a count integer with K/M suffix abbreviations.
  ///
  /// - Values >= 1,000,000 are shown as `X.XM`
  /// - Values >= 1,000 are shown as `X.XK`
  /// - Smaller values are shown as-is
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          key: const Key('profile_stats_followers_button'),
          onTap: onFollowersTap,
          child: Text(
            '${_formatCount(followersCount)} Followers',
            key: const Key('profile_stats_followers_text'),
            style: AppTheme.bodyMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('·', style: AppTheme.bodyMedium),
        ),
        InkWell(
          key: const Key('profile_stats_following_button'),
          onTap: onFollowingTap,
          child: Text(
            '${_formatCount(followingCount)} Following',
            key: const Key('profile_stats_following_text'),
            style: AppTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
