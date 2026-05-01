// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
class ProfileAvatar extends StatelessWidget {
  /// The network URL of the user's profile picture.
  ///
  /// If `null`, a default person icon is shown instead.
  final String? avatarUrl;

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
          // Use CachedNetworkImage for better error handling
          avatarUrl != null
              ? CachedNetworkImage(
                  imageUrl: avatarUrl!,
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
