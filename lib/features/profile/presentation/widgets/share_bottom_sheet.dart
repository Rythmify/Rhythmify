import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../../../core/theme/app_theme.dart';
import 'profile_avatar.dart';

class ShareBottomSheet extends StatelessWidget {
  final ProfileEntity profile;

  const ShareBottomSheet({super.key, required this.profile});

  String get _profileUrl =>
      'https://rythmify.com/users/${profile.id}';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Profile preview ───────────────────────────────────────
          Row(
            children: [
              ProfileAvatar(
                avatarUrl: profile.avatarUrl,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.displayName, style: AppTheme.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    '${profile.followersCount} Followers · ${profile.tracksCount} Tracks',
                    style: AppTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Share options ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _shareOption(
                context,
                icon: Icons.send,
                label: 'Message',
                onTap: () {
                  Navigator.pop(context);
                  Share.share(_profileUrl);
                },
              ),
              _shareOption(
                context,
                icon: Icons.copy,
                label: 'Copy Link',
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _profileUrl));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard')),
                  );
                },
              ),
              _shareOption(
                context,
                icon: Icons.share,
                label: 'More',
                onTap: () {
                  Navigator.pop(context);
                  Share.share(
                    'Check out ${profile.displayName} on Rythmify! $_profileUrl',
                  );
                },
              ),
              _shareOption(
                context,
                icon: Icons.qr_code,
                label: 'QR code',
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── View info ─────────────────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text('View info', style: AppTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shareOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.textPrimary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTheme.labelSmall),
        ],
      ),
    );
  }
}