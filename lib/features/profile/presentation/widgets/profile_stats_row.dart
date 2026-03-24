import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class ProfileStatsRow extends StatelessWidget {
  final int followersCount;
  final int followingCount;

  const ProfileStatsRow({
    super.key,
    required this.followersCount,
    required this.followingCount,
  });

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
        Text(
          '${_formatCount(followersCount)} Followers',
          key: const Key('profile_stats_followers_text'),
          style: AppTheme.bodyMedium,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('·', style: AppTheme.bodyMedium),
        ),
        Text(
          '${_formatCount(followingCount)} Following',
          key: const Key('profile_stats_following_text'),
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }
}
