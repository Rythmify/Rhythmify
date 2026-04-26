// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../domain/entities/profile_entity.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import 'profile_avatar.dart';

class ShareBottomSheet extends ConsumerWidget {
  final ProfileEntity profile;

  const ShareBottomSheet({super.key, required this.profile});

  String get _profileUrl => 'https://rythmify.com/users/${profile.id}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom +
            64, // Extra padding for miniplayer
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ── Handle ─────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// ── Profile preview ────────────────────────────────────
          Row(
            children: [
              ProfileAvatar(avatarUrl: profile.avatarUrl, radius: 24),
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

              const Spacer(),
            ],
          ),

          const SizedBox(height: 24),

          /// ── Share options (SCROLLABLE) ─────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _shareOption(
                  context,
                  key: const Key('profile_share_message_button'),
                  icon: Icons.send,
                  label: 'Message',
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(_profileUrl);
                  },
                ),

                const SizedBox(width: 16),

                _shareOption(
                  context,
                  key: const Key('profile_share_copy_link_button'),
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

                const SizedBox(width: 16),

                _shareOption(
                  context,
                  key: const Key('profile_share_whatsapp_button'),
                  icon: FontAwesomeIcons.whatsapp,
                  label: 'WhatsApp',
                  iconColor: Colors.white,
                  backgroundColor: AppTheme.whatsApp,
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(_profileUrl);
                  },
                ),

                const SizedBox(width: 16),

                _shareOption(
                  context,
                  key: const Key('profile_share_status_button'),
                  icon: FontAwesomeIcons.whatsapp,
                  label: 'status',
                  iconColor: Colors.white,
                  backgroundColor: AppTheme.whatsApp,
                  onTap: () {
                    Navigator.pop(context);
                    Share.share(_profileUrl);
                  },
                ),

                const SizedBox(width: 16),

                _shareOption(
                  context,
                  key: const Key('profile_share_stories_button'),
                  icon: FontAwesomeIcons.instagram,
                  label: 'Stories',
                  iconColor: Colors.white,
                  backgroundColor: AppTheme.instagram,
                  onTap: () {},
                ),

                const SizedBox(width: 16),

                _shareOption(
                  context,
                  key: const Key('profile_share_sms_button'),
                  icon: Icons.sms,
                  label: 'SMS',
                  iconColor: Colors.white,
                  backgroundColor: AppTheme.sms,
                  onTap: () {},
                ),

                const SizedBox(width: 16),

                _shareOption(
                  context,
                  key: const Key('profile_share_qr_code_button'),
                  icon: Icons.qr_code,
                  label: 'QR code',
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// Divider
          Divider(
            color: AppTheme.textSecondary.withValues(alpha: 0.2),
            height: 32,
          ),

          /// ── View info ──────────────────────────────────────────
          GestureDetector(
            key: const Key('profile_share_view_info_gesture'),
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

          /// ── Block user ─────────────────────────────────────────────
          const SizedBox(height: 20),
          GestureDetector(
            key: const Key('profile_share_block_gesture'),
            onTap: () {
              Navigator.pop(context);
              _confirmBlock(context, ref);
            },
            child: Row(
              children: [
                const Icon(
                  Icons.block_rounded,
                  color: Colors.redAccent,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  'Block user',
                  style: AppTheme.bodyLarge.copyWith(color: Colors.redAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before blocking the user.
  Future<void> _confirmBlock(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Block this user?', style: AppTheme.titleMedium),
        content: Text(
          'They won\'t see your profile and you won\'t see theirs.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: AppTheme.labelLarge.copyWith(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Block',
              style: AppTheme.labelLarge.copyWith(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref
          .read(publicProfileProvider(profile.id).notifier)
          .blockUser(profile.id);
    }
  }

  /// ── Share button widget ──────────────────────────────────────
  Widget _shareOption(
    BuildContext context, {
    Key? key,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppTheme.shareCircle,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppTheme.textPrimary,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTheme.labelSmall),
        ],
      ),
    );
  }
}
