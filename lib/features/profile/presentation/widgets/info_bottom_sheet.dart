import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../../../core/theme/app_theme.dart';

/// Bottom sheet presenting secondary profile details and metadata.

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

          //  Location 
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

          //  Bio
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            Text(
              profile.bio!,
              key: const Key('profile_info_bio_text'),
              style: AppTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],

          if (_socialItems.isNotEmpty) ...[
            Text('Social links', style: AppTheme.titleMedium),
            const SizedBox(height: 8),
            ..._socialItems.map(
              (item) => ListTile(
                key: Key('profile_info_social_${item.name.toLowerCase()}'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: FaIcon(
                  item.icon,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                title: Text(item.name, style: AppTheme.bodyMedium),
                onTap: () => _openExternalUrl(item.url),
              ),
            ),
            const SizedBox(height: 8),
          ],

          //  Stats 
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

  List<_SocialItem> get _socialItems => [
    if (profile.instagramUrl != null && profile.instagramUrl!.trim().isNotEmpty)
      _SocialItem(
        name: 'Instagram',
        url: profile.instagramUrl!,
        icon: FontAwesomeIcons.instagram,
      ),
    if (profile.facebookUrl != null && profile.facebookUrl!.trim().isNotEmpty)
      _SocialItem(
        name: 'Facebook',
        url: profile.facebookUrl!,
        icon: FontAwesomeIcons.facebook,
      ),
    if (profile.githubUrl != null && profile.githubUrl!.trim().isNotEmpty)
      _SocialItem(
        name: 'GitHub',
        url: profile.githubUrl!,
        icon: FontAwesomeIcons.github,
      ),
  ];

  Future<void> _openExternalUrl(String rawUrl) async {
    final url = Uri.parse(rawUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}

class _SocialItem {
  final String name;
  final String url;
  final IconData icon;

  const _SocialItem({
    required this.name,
    required this.url,
    required this.icon,
  });
}
