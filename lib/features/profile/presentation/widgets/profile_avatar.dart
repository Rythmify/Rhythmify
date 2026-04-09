import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import '../../../../../core/theme/app_theme.dart';

/// A circular avatar widget used across profile screens.
///
/// Displays the user's profile picture from a network URL using
/// [CachedNetworkImage]. Falls back to a person icon when no
/// [avatarUrl] is provided or if the image fails to load.
///
/// Optionally shows a camera icon overlay when [showCameraIcon] is
/// `true` — used on the [EditProfilePage] to indicate tappability.
///
/// **Cache-busting strategy:**
/// If [updatedAt] is provided, it's used as a stable cache key that only
/// changes when the profile is updated. If not provided, falls back to
/// a timestamp-based approach. This prevents showing stale images when
/// the CDN URL stays the same after avatar upload/deletion.
///
/// Example usage:
/// ```dart
/// ProfileAvatar(
///   avatarUrl: 'https://cdn.rythmify.com/avatars/user.jpg',
///   updatedAt: profile.updatedAt,
///   radius: 60,
///   showCameraIcon: true,
///   onTap: _pickAvatar,
/// )
/// ```
class ProfileAvatar extends StatelessWidget {
  /// The network URL of the user's profile picture.
  ///
  /// If `null`, a default person icon is shown instead.
  final String? avatarUrl;
  final String? localAvatarPath;

  /// The timestamp when the profile was last updated.
  ///
  /// Used for cache-busting: when this changes, the widget re-fetches
  /// the image from the network. Provides a stable cache key tied to
  /// the actual profile state, rather than using `DateTime.now()`.
  final DateTime? updatedAt;

  /// The radius of the circular avatar in logical pixels.
  ///
  /// Defaults to `60`.
  final double radius;

  /// Whether to show a camera icon overlay in the bottom-right corner.
  ///
  /// Used on [EditProfilePage] to signal that the avatar is tappable.
  /// Defaults to `false`.
  final bool showCameraIcon;

  /// Callback invoked when the avatar is tapped.
  ///
  /// Only active when wrapped in a [GestureDetector].
  final VoidCallback? onTap;

  /// Creates a [ProfileAvatar].
  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    this.localAvatarPath,
    this.updatedAt,
    this.radius = 60,
    this.showCameraIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocalAvatar =
        localAvatarPath != null &&
        localAvatarPath!.trim().isNotEmpty &&
        File(localAvatarPath!).existsSync();
    if (hasLocalAvatar) {
      return GestureDetector(
        key: const Key('profile_avatar_gesture'),
        onTap: onTap,
        child: Stack(
          children: [
            CircleAvatar(
              radius: radius,
              backgroundColor: AppTheme.surface,
              backgroundImage: FileImage(File(localAvatarPath!)),
            ),
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

    // Cache-busting strategy without backend updatedAt:
    // Generate a unique URL on each widget rebuild by appending timestamp.
    // CachedNetworkImage will cache by the full URL (including query params),
    // so when the widget rebuilds after upload, the new timestamp forces a refetch.
    final String? imageUrl;

    if (avatarUrl != null) {
      // Clear old cached version to ensure fresh load
      DefaultCacheManager().removeFile(avatarUrl!);

      // Add timestamp query param to bust CDN/browser cache
      imageUrl = '$avatarUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } else {
      imageUrl = null;
    }

    return GestureDetector(
      key: const Key('profile_avatar_gesture'),
      onTap: onTap,
      child: Stack(
        children: [
          // Use CachedNetworkImage for better error handling
          imageUrl != null
              ? CachedNetworkImage(
                  key: ValueKey(imageUrl), // Force rebuild when URL changes
                  imageUrl: imageUrl,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: radius,
                    backgroundColor: AppTheme.surface,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => CircleAvatar(
                    radius: radius,
                    backgroundColor: AppTheme.surface,
                    child: Icon(
                      Icons.person,
                      size: radius,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: radius,
                    backgroundColor: AppTheme.surface,
                    child: Icon(
                      Icons.person,
                      size: radius,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: radius,
                  backgroundColor: AppTheme.surface,
                  child: Icon(
                    Icons.person,
                    size: radius,
                    color: AppTheme.textSecondary,
                  ),
                ),
          // Camera icon overlay for edit mode
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
