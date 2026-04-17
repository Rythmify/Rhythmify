import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/profile_user_summary.dart';
import '../../../../core/theme/app_theme.dart';

/// Lightweight user row used in followers/following lists.
class ProfileUserListTile extends StatelessWidget {
  /// User to render.
  final ProfileUserSummary user;

  /// Creates a [ProfileUserListTile].
  const ProfileUserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('profile_connections_user_${user.id}_tile'),
      leading: ClipOval(
        child: (user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty)
            ? CachedNetworkImage(
                imageUrl: user.avatarUrl!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => _buildAvatarFallback(),
                placeholder: (_, _) => _buildAvatarFallback(),
              )
            : _buildAvatarFallback(),
      ),
      title: Text(user.displayName, style: AppTheme.labelLarge),
      subtitle: Text(
        '@${user.username}',
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }

  /// Fallback avatar when network image is unavailable.
  Widget _buildAvatarFallback() {
    return Container(
      width: 44,
      height: 44,
      color: AppTheme.surface,
      child: const Icon(Icons.person, color: AppTheme.textSecondary),
    );
  }
}
