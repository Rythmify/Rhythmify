import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/profile_user_summary.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';

/// Lightweight user row used in followers/following lists.
class ProfileUserListTile extends ConsumerWidget {
  /// User to render.
  final ProfileUserSummary user;

  /// Creates a [ProfileUserListTile].
  const ProfileUserListTile({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(publicProfileProvider(user.id));

    // Load profile if not already loaded
    ref.listen(publicProfileProvider(user.id), (prev, curr) {});

    // Auto-load profile on first build
    if (profileState is ProfileInitial) {
      Future.microtask(() {
        ref
            .read(publicProfileProvider(user.id).notifier)
            .loadProfile(userId: user.id);
      });
    }

    final isFollowing = switch (profileState) {
      ProfileLoaded(:final profile) => profile.isFollowing,
      _ => false,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('profile_connections_user_${user.id}_tile'),
        onTap: () => context.push('/profile/${user.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.displayName, style: AppTheme.labelLarge),
                    Text(
                      '@${user.username}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  final notifier = ref.read(
                    publicProfileProvider(user.id).notifier,
                  );
                  if (isFollowing) {
                    notifier.unfollowUser(userId: user.id);
                  } else {
                    notifier.followUser(userId: user.id);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isFollowing ? 'Following' : 'Follow',
                    style: AppTheme.labelLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
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
