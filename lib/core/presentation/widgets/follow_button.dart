import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// ── FollowButton ──────────────────────────────────────────────────────────────

/// A universal Follow / Following pill button with **optimistic UI**.
///
/// The button flips its visual state **immediately** on tap without waiting
/// for the API response.  If the server call fails the state is rolled back
/// to what it was before the tap, keeping the UI consistent with reality.
///
/// State machine per tap:
/// ```
/// Tap ─► flip _optimisticFollowing immediately (UI updates)
///      ─► call follow / unfollow API in background
///      ─► success: provider refreshes, _optimisticFollowing cleared (server wins)
///      ─► failure: roll back _optimisticFollowing to previous value
/// ```
///
/// Handles all display states:
/// - **Own profile** (`targetUserId == currentUser.id`): renders [SizedBox.shrink].
/// - **Unauthenticated**: disabled "Follow" pill.
/// - **Following**: outlined pill, label "Following".
/// - **Not following**: orange-filled pill, label "Follow".
///
/// Usage:
/// ```dart
/// // Profile page (default padding):
/// FollowButton(targetUserId: profile.id)
///
/// // Followers / following list tile (compact padding):
/// FollowButton(targetUserId: user.id, compact: true)
///
/// // Custom representation (e.g. Icon):
/// FollowButton(
///   targetUserId: user.id,
///   builder: (context, isFollowing, isInFlight, toggle) => IconButton(...)
/// )
/// ```
class FollowButton extends ConsumerStatefulWidget {
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
  )? builder;

  /// Creates a [FollowButton].
  const FollowButton({
    super.key,
    required this.targetUserId,
    this.compact = false,
    this.builder,
  });

  @override
  ConsumerState<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends ConsumerState<FollowButton> {
  /// Optimistic follow state shown in the UI while the API call is in flight.
  ///
  /// `null` means "use the real value from [followStatusProvider]".
  /// Set to the desired new value immediately on tap, cleared once the server
  /// responds (success) or rolled back (failure).
  bool? _optimisticFollowing;

  /// Guards against concurrent taps while a call is already in flight.
  bool _isInFlight = false;

  /// Toggles follow state with optimistic UI update.
  ///
  /// 1. Flips [_optimisticFollowing] instantly so the button redraws.
  /// 2. Ensures the profile notifier has a loaded profile (needed so the
  ///    notifier's guard does not return early).
  /// 3. Fires the API call in the background.
  /// 4. On failure, rolls [_optimisticFollowing] back to the previous value.
  /// 5. On success, clears [_optimisticFollowing] so the provider's real value
  ///    (refreshed from the backend) takes over.
  Future<void> _toggle(bool currentlyFollowing) async {
    if (_isInFlight) return;

    // ── Step 1: optimistic flip ──────────────────────────────────────────
    setState(() {
      _optimisticFollowing = !currentlyFollowing;
      _isInFlight = true;
    });

    final notifier = ref.read(
      publicProfileProvider(widget.targetUserId).notifier,
    );

    // ── Step 2: ensure profile is loaded ────────────────────────────────
    final profileState = ref.read(publicProfileProvider(widget.targetUserId));
    if (profileState is ProfileInitial) {
      await notifier.loadProfile(userId: widget.targetUserId);
    }

    // ── Step 3: API call ─────────────────────────────────────────────────
    bool success = false;
    try {
      if (currentlyFollowing) {
        await notifier.unfollowUser(userId: widget.targetUserId);
      } else {
        await notifier.followUser(userId: widget.targetUserId);
      }
      success = true;
    } catch (_) {
      success = false;
    }

    if (!mounted) return;

    if (success) {
      // ── Step 5: clear optimistic override — provider now has real value ─
      setState(() {
        _optimisticFollowing = null;
        _isInFlight = false;
      });
    } else {
      // ── Step 4: roll back on failure ─────────────────────────────────
      setState(() {
        _optimisticFollowing = currentlyFollowing;
        _isInFlight = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Hide entirely for own profile.
    if (authState is AuthAuthenticated &&
        authState.user.id == widget.targetUserId) {
      return const SizedBox.shrink();
    }

    // Use optimistic value when in flight, otherwise use provider's real value.
    final realFollowing = ref.watch(followStatusProvider(widget.targetUserId));
    final isFollowing = _optimisticFollowing ?? realFollowing;

    final isAuthenticated = authState is AuthAuthenticated;

    if (widget.builder != null) {
      return widget.builder!(
        context,
        isFollowing,
        _isInFlight,
        isAuthenticated && !_isInFlight ? () => _toggle(isFollowing) : () {},
      );
    }

    final hPad = widget.compact ? 16.0 : 20.0;
    final vPad = widget.compact ? 6.0 : 8.0;

    return GestureDetector(
      key: Key('follow_button_${widget.targetUserId}'),
      onTap: isAuthenticated && !_isInFlight
          ? () => _toggle(isFollowing)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: isFollowing ? Colors.transparent : AppTheme.primaryBrand,
          border: Border.all(
            color: isFollowing
                ? AppTheme.textSecondary.withValues(alpha: 0.5)
                : AppTheme.primaryBrand,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          key: Key('follow_button_label_${widget.targetUserId}'),
          style: AppTheme.labelLarge,
        ),
      ),
    );
  }
}
