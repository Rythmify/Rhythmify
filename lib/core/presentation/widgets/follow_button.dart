import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/notifications/presentation/providers/follow_state_provider.dart';
import 'package:rythmify/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:rythmify/features/profile/domain/entities/profile_user_summary.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_connections_provider.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_connections_state.dart';
import '../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../features/authentication/presentation/providers/auth_state.dart';
import '../../../features/profile/presentation/providers/profile_provider.dart';
import '../../../features/profile/presentation/providers/profile_state.dart';
import '../../theme/app_theme.dart';

// ── Follow-status provider ────────────────────────────────────────────────────

/// Tracks the live follow-state for [targetUserId] reactively across the app.
///
/// Reads from [publicProfileProvider] which is keyed by user ID and always
/// reflects the latest follow/unfollow result.  Any widget that watches this
/// provider will rebuild automatically after a follow or unfollow action
/// completes — no manual state passing required.
///
/// Returns `false` when:
/// - [targetUserId] matches the authenticated user's own ID (cannot follow self).
/// - The profile has not been loaded yet.
/// - The user is unauthenticated.
final followStatusProvider = Provider.family<bool, String>((ref, targetUserId) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated && authState.user.id == targetUserId) {
    return false;
  }
  // If the full profile is loaded, use it (most accurate)
  final profileState = ref.watch(publicProfileProvider(targetUserId));
  if (profileState is ProfileLoaded) return profileState.profile.isFollowing;

  // Fallback: check connections list for initial value without loading full profile
  final connectionsState = ref.watch(profileConnectionsProvider);
  if (connectionsState is ProfileConnectionsLoaded) {
    final match = connectionsState.users.cast<ProfileUserSummary?>().firstWhere(
      (u) => u?.id == targetUserId,
      orElse: () => null,
    );
    if (match != null) return match.isFollowing;
  }
  return false;
});

class FollowButton extends ConsumerWidget {
  /// The UUID of the user to follow or unfollow.
  final String targetUserId;

  /// When `true`, uses smaller horizontal/vertical padding for list-tile use.
  ///
  /// Compact: 16 × 6 px.  Default: 20 × 8 px.
  final bool compact;

  /// Optional custom builder for the follow widget.
  ///
  /// If provided, this builder is responsible for rendering the UI and
  /// calling the `toggle` callback. The `isFollowing` and `isInFlight`
  /// states are provided for reactive updates.
  final Widget Function(
    BuildContext context,
    bool isFollowing,
    bool isInFlight,
    VoidCallback toggle,
  )?
  builder;

  /// Creates a [FollowButton].
  const FollowButton({
    super.key,
    required this.targetUserId,
    this.compact = false,
    this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Hide entirely for own profile.
    if (authState is AuthAuthenticated && authState.user.id == targetUserId) {
      return const SizedBox.shrink();
    }

    final followMap = ref.watch(followStateProvider);
    final fallbackFollowing = ref.watch(followStatusProvider(targetUserId));
    final isFollowing = followMap[targetUserId] ?? fallbackFollowing;
    final isInFlight = false;

    final isAuthenticated = authState is AuthAuthenticated;
    final toggle = isAuthenticated
        ? () => ref
              .read(notificationsProvider.notifier)
              .toggleFollow(targetUserId, isFollowing)
        : () {};

    if (builder != null) {
      return builder!(context, isFollowing, isInFlight, toggle);
    }

    final hPad = compact ? 12.0 : 16.0;
    final vPad = compact ? 6.0 : 8.0;

    return IgnorePointer(
      ignoring: !isAuthenticated,
      child: GestureDetector(
        key: Key('follow_button_$targetUserId'),
        onTap: toggle,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
          decoration: BoxDecoration(
            color: isFollowing ? const Color(0xFF3C3C3C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            key: Key('follow_button_label_$targetUserId'),
            style: AppTheme.labelLarge.copyWith(
              color: isFollowing ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
