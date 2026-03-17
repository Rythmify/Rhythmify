import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/track_list_tile.dart';
import '../widgets/share_bottom_sheet.dart';
import '../widgets/info_bottom_sheet.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';

class PublicProfilePage extends ConsumerStatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  ConsumerState<PublicProfilePage> createState() =>
      _PublicProfilePageState();
}

class _PublicProfilePageState extends ConsumerState<PublicProfilePage> {
  final _scrollController = ScrollController();
  bool _showTitleInAppBar = false;

  /// Threshold in pixels – roughly avatar (120) + spacing (12) + name line (48)
  static const double _nameStickyThreshold = 180.0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(profileProvider.notifier).loadProfile(userId: widget.userId));

    _scrollController.addListener(() {
      // Show / hide app-bar title based on scroll position
      final shouldShow =
          _scrollController.offset >= _nameStickyThreshold;
      if (shouldShow != _showTitleInAppBar) {
        setState(() => _showTitleInAppBar = shouldShow);
      }

      // Paginate liked tracks
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final state = ref.read(profileProvider);
        if (state is ProfileLoaded) {
          ref.read(profileProvider.notifier).loadLikedTracks(
                userId: widget.userId,
              );
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showShareSheet(BuildContext context, ProfileLoaded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareBottomSheet(profile: state.profile),
    );
  }

  void _showInfoSheet(BuildContext context, ProfileLoaded state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => InfoBottomSheet(profile: state.profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);
    final isOwnProfile = authState is AuthAuthenticated
        ? authState.user.id == widget.userId
        : false;

    // Resolve display name for the app bar
    final String? displayName = profileState is ProfileLoaded
        ? profileState.profile.displayName
        : null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: AnimatedOpacity(
          opacity: _showTitleInAppBar ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            displayName ?? '',
            style: AppTheme.appBarTitle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cast),
            onPressed: () {},
          ),
          IconButton(
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
                  onPressed: () => ref
                      .read(profileProvider.notifier)
                      .loadProfile(userId: widget.userId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ProfileLoaded() => _buildLoaded(
            context,
            profileState as ProfileLoaded,
            isOwnProfile,
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }

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
                // ── Avatar ──────────────────────────────────────────
                ProfileAvatar(
                  avatarUrl: state.profile.avatarUrl,
                  radius: 60,
                ),

                const SizedBox(height: 12),

                // ── Display name ─────────────────────────────────────
                Text(
                  state.profile.displayName,
                  style: AppTheme.headlineLarge,
                ),

                const SizedBox(height: 4),

                // ── Location ─────────────────────────────────────────
                if (state.profile.city != null ||
                    state.profile.country != null)
                  Text(
                    [state.profile.city, state.profile.country]
                        .where((e) => e != null && e.isNotEmpty)
                        .join(', '),
                    style: AppTheme.bodyMedium,
                  ),

                const SizedBox(height: 4),

                // ── Followers / Following ────────────────────────────
                ProfileStatsRow(
                  followersCount: state.profile.followersCount,
                  followingCount: state.profile.followingCount,
                ),

                const SizedBox(height: 16),

                // ── Action buttons row ───────────────────────────────
                Row(
                  children: [
                    // Edit or Follow button
                    if (isOwnProfile)
                      GestureDetector(
                        onTap: () => context.push('/profile/edit'),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: AppTheme.textSecondary,
                          size: 22,
                        ),
                      )
                    else
                      GestureDetector(
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
                              color: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            state.profile.isFollowing
                                ? 'Following'
                                : 'Follow',
                            style: AppTheme.labelLarge,
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Shuffle button
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.shuffle,
                        color: AppTheme.textSecondary,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Play button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: AppTheme.textPrimary,
                        size: 28,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // ── Tracks or empty state ──────────────────────────────────
        if (state.likedTracks.isEmpty && !state.isLoadingTracks)
          SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Seems a little quiet over here',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tracks you like, repost or upload will appear here.',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
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
                return TrackListTile(
                  track: state.likedTracks[index],
                );
              },
              childCount: state.likedTracks.length + 1,
            ),
          ),
      ],
    );
  }
}