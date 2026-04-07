import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/player/presentation/providers/player_provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/track_list_tile.dart';
import '../widgets/share_bottom_sheet.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';

/// A full-screen profile page showing a user's public information and tracks.
///
/// Can display both the authenticated user's own profile and any other user's
/// profile. The [userId] parameter drives which profile is fetched:
/// - Pass `'me'` or the current user's own ID → renders own profile
///   (shows an Edit button, no Follow button).
/// - Pass any other user's ID → renders their profile (shows Follow/Following
///   button, no Edit button).
///
/// ### Loading strategy
///
/// Profile loading is NOT triggered in [build] of [ProfileNotifier]. Instead,
/// [initState] calls [ProfileNotifier.loadProfile] via `Future.microtask`
/// to avoid calling `setState` during the widget build phase.
///
/// ### Scroll-based pagination
///
/// A [ScrollController] listens to scroll position. When within 200px of the
/// bottom, [ProfileNotifier.loadLikedTracks] is called to fetch the next page.
///
/// ### userId resolution
///
/// [_resolvedUserId] is computed once in [initState] by comparing [userId]
/// against the currently authenticated user's ID. Own profiles always resolve
/// to `'me'` so the `/users/me` endpoint is hit rather than `/users/{id}`.
///
/// ### Navigation
///
/// - Edit button → `context.push('/profile/edit')`
/// - Track tap → [PlayerNotifier.playOptimistic]
/// - Share (⋮) → shows [ShareBottomSheet] as a modal bottom sheet
class PublicProfilePage extends ConsumerStatefulWidget {
  /// The ID of the user whose profile to display.
  ///
  /// Pass `'me'` to explicitly request the authenticated user's own profile.
  /// Pass any other UUID for another user's profile.
  final String userId;

  /// Creates a [PublicProfilePage] for the user with [userId].
  const PublicProfilePage({super.key, required this.userId});

  @override
  ConsumerState<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends ConsumerState<PublicProfilePage> {
  final _scrollController = ScrollController();

  /// The resolved user ID used for all API calls on this page.
  ///
  /// Set to `'me'` when [widget.userId] matches the authenticated user's ID
  /// or is already `'me'`. Otherwise equals [widget.userId] as-is.
  late String _resolvedUserId;

  @override
  void initState() {
    super.initState();

    final authState = ref.read(authProvider);
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : null;

    _resolvedUserId = widget.userId == currentUserId || widget.userId == 'me'
        ? 'me'
        : widget.userId;

    // Trigger profile load after the build phase completes
    Future.microtask(
      () => ref
          .read(profileProvider.notifier)
          .loadProfile(userId: _resolvedUserId),
    );

    // Scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final s = ref.read(profileProvider);
        if (s is ProfileLoaded) {
          ref
              .read(profileProvider.notifier)
              .loadLikedTracks(userId: _resolvedUserId);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Opens the [ShareBottomSheet] as a transparent modal bottom sheet.
  void _showShareSheet(BuildContext context, ProfileLoaded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareBottomSheet(profile: state.profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : null;
    final isOwnProfile =
        widget.userId == currentUserId || widget.userId == 'me';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('public_profile_back_button'),
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            key: const Key('public_profile_cast_button'),
            icon: const Icon(Icons.cast),
            onPressed: () {},
          ),
          IconButton(
            key: const Key('public_profile_more_button'),
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              if (profileState is ProfileLoaded) {
                _showShareSheet(context, profileState);
              }
            },
          ),
        ],
      ),
      body: switch (profileState) {
        ProfileInitial() => const SizedBox.shrink(),
        ProfileLoading() => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrand),
        ),
        ProfileError(:final message) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(message, style: AppTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const Key('public_profile_retry_button'),
                onPressed: () => ref
                    .read(profileProvider.notifier)
                    .loadProfile(userId: _resolvedUserId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        ProfileLoaded() => _buildLoaded(context, profileState, isOwnProfile),
        _ => const SizedBox.shrink(),
      },
    );
  }

  /// Builds the main scrollable content when the profile is loaded.
  ///
  /// Uses a [CustomScrollView] with a [SliverToBoxAdapter] for the header
  /// and either [SliverFillRemaining] (empty state) or [SliverList]
  /// (track list with pagination spinner).
  Widget _buildLoaded(
    BuildContext context,
    ProfileLoaded state,
    bool isOwnProfile,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileAvatar(avatarUrl: state.profile.avatarUrl, radius: 60),
                const SizedBox(height: 12),
                Text(state.profile.displayName, style: AppTheme.headlineLarge),
                const SizedBox(height: 4),
                if (state.profile.city != null || state.profile.country != null)
                  Text(
                    [
                      state.profile.city,
                      state.profile.country,
                    ].where((e) => e != null && e.isNotEmpty).join(', '),
                    style: AppTheme.bodyMedium,
                  ),
                const SizedBox(height: 4),
                ProfileStatsRow(
                  followersCount: state.profile.followersCount,
                  followingCount: state.profile.followingCount,
                ),
                const SizedBox(height: 12),

                const SizedBox(height: 16),
                Row(
                  children: [
                    if (isOwnProfile)
                      GestureDetector(
                        key: const Key('public_profile_edit_gesture'),
                        onTap: () => context.push('/profile/edit'),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: AppTheme.textSecondary,
                          size: 22,
                        ),
                      )
                    else
                      GestureDetector(
                        key: const Key('public_profile_follow_gesture'),
                        onTap: () {
                          if (state.profile.isFollowing) {
                            ref
                                .read(profileProvider.notifier)
                                .unfollowUser(userId: widget.userId);
                          } else {
                            ref
                                .read(profileProvider.notifier)
                                .followUser(userId: widget.userId);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            state.profile.isFollowing ? 'Following' : 'Follow',
                            style: AppTheme.labelLarge,
                          ),
                        ),
                      ),
                    const Spacer(),
                    GestureDetector(
                      key: const Key('public_profile_shuffle_gesture'),
                      onTap: () {},
                      child: const Icon(
                        Icons.shuffle,
                        color: AppTheme.textSecondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      key: const Key('public_profile_play_button'),
                      onTap: () {},
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isOwnProfile && state.likedTracks.isEmpty
                              ? AppTheme.textSecondary.withValues(alpha: 0.2)
                              : AppTheme.textSecondary.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: AppTheme.textPrimary,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Empty state
        if (state.likedTracks.isEmpty && !state.isLoadingTracks)
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Seems a little quiet over here',
                    key: const Key('public_profile_empty_headline_text'),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tracks you like, repost or upload will\nappear here.',
                    key: const Key('public_profile_empty_body_text'),
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              // Pagination spinner at the end of the list
              if (index == state.likedTracks.length) {
                return state.isLoadingTracks
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryBrand,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }

              final track = state.likedTracks[index];

              return TrackListTile(
                key: Key('item_${track.id}'),
                track: track,
                onTap: () {
                  ref.read(playerStateProvider.notifier).playOptimistic(track);
                },
                onMoreTap: () {},
              );
            }, childCount: state.likedTracks.length + 1),
          ),
      ],
    );
  }
}
