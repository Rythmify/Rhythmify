import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double radius;
  final bool showCameraIcon;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    this.radius = 60,
    this.showCameraIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('profile_avatar_gesture'),
      onTap: onTap,
      child: Stack(
        children: [
          // ── Avatar circle ──────────────────────────────────────────
          CircleAvatar(
            radius: radius,
            backgroundColor: AppTheme.surface,
            backgroundImage: avatarUrl != null
                ? CachedNetworkImageProvider(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? Icon(
                    Icons.person,
                    size: radius,
                    color: AppTheme.textSecondary,
                  )
                : null,
          ),

          // ── Camera icon overlay (edit mode only) ───────────────────
          if (showCameraIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}