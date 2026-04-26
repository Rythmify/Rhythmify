import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_user_summary.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/follow_button.dart';

/// Lightweight user row used in followers / following lists.
///
/// Displays the user's avatar, display name, and username on the left,
/// and a [FollowButton] on the right.  Tapping the row navigates to
/// `/profile/{user.id}`.
///
/// The follow state is managed entirely by [FollowButton] via
/// [followStatusProvider] — no local state or provider watch needed here.
class ProfileUserListTile extends ConsumerWidget {
  /// The user to render in this tile.
  final ProfileUserSummary user;

  /// Creates a [ProfileUserListTile].
  const ProfileUserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('profile_connections_user_${user.id}_tile'),
        onTap: () => context.push('/home/profile/${user.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // ── Avatar ────────────────────────────────────────────────
              ClipOval(
                child:
                    (user.avatarUrl != null &&
                        user.avatarUrl!.trim().isNotEmpty)
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
              const SizedBox(width: 12),

              // ── Name + username ───────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: AppTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '@${user.username}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // ── Universal Follow button ───────────────────────────────
              FollowButton(
                key: Key('follow_button_tile_${user.id}'),
                targetUserId: user.id,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fallback avatar shown when the network image is unavailable.
  Widget _buildAvatarFallback() {
    return Container(
      width: 44,
      height: 44,
      color: AppTheme.surface,
      child: const Icon(Icons.person, color: AppTheme.textSecondary),
    );
  }
}
