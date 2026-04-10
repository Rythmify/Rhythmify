/// Bottom sheet presenting secondary profile details and metadata.
import 'package:flutter/material.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../../../core/theme/app_theme.dart';

class InfoBottomSheet extends StatelessWidget {
  final ProfileEntity profile;

  const InfoBottomSheet({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Display name ──────────────────────────────────────────
          Text(
            profile.displayName,
            key: const Key('profile_info_name_text'),
            style: AppTheme.titleLarge,
          ),

          const SizedBox(height: 16),

          // ── Location ──────────────────────────────────────────────
          if (profile.city != null || profile.country != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  [
                    profile.city,
                    profile.country,
                  ].where((e) => e != null && e.isNotEmpty).join(', '),
                  key: const Key('profile_info_location_text'),
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // ── Bio ───────────────────────────────────────────────────
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            Text(
              profile.bio!,
              key: const Key('profile_info_bio_text'),
              style: AppTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],

          // ── Stats ─────────────────────────────────────────────────
          Row(
            children: [
              _statItem(
                '${profile.followersCount}',
                'Followers',
                key: const Key('profile_info_followers_stat'),
              ),
              const SizedBox(width: 24),
              _statItem(
                '${profile.followingCount}',
                'Following',
                key: const Key('profile_info_following_stat'),
              ),
              const SizedBox(width: 24),
              _statItem(
                '${profile.tracksCount}',
                'Tracks',
                key: const Key('profile_info_tracks_stat'),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _statItem(String count, String label, {Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(count, style: AppTheme.titleMedium),
        Text(label, style: AppTheme.labelSmall),
      ],
    );
  }
}
