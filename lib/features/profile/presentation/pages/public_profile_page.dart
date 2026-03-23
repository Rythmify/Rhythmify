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
import '../../../player/presentation/providers/player_provider.dart';

class PublicProfilePage extends ConsumerStatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  ConsumerState<PublicProfilePage> createState() =>
      _PublicProfilePageState();
}

class _PublicProfilePageState extends ConsumerState<PublicProfilePage> {
  final _scrollController = ScrollController();
  late String _resolvedUserId;

  @override
  void initState() {
    super.initState();

    final authState = ref.read(authProvider);
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;

    _resolvedUserId =
        widget.userId == currentUserId || widget.userId == 'me'
            ? 'me'
            : widget.userId;

    // Always explicitly trigger load
    Future.microtask(() =>
        ref.read(profileProvider.notifier).loadProfile(userId: _resolvedUserId));

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        final s = ref.read(profileProvider);
        if (s is ProfileLoaded) {
          ref.read(profileProvider.notifier).loadLikedTracks(
                userId: _resolvedUserId,
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

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authProvider);
    final currentUserId =
        authState is AuthAuthenticated ? authState.user.id : null;
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
        ProfileLoaded() => _buildLoaded(
            context,
            profileState,
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
                              color: AppTheme.textSecondary
                                  .withValues(alpha: 0.5),
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

                    Container(
                      key: const Key('public_profile_play_button'),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withValues(alpha: 0.3),
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
                // ── Loading spinner at the bottom ──────────────────
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
                  // ── Tap → play this track immediately ─────────────
                  onTap: () {
                    ref
                        .read(playerStateProvider.notifier)
                        .playOptimistic(track);
                  },
                  onMoreTap: () {
                    // TODO: open track options bottom sheet
                  },
                );
              },
              childCount: state.likedTracks.length + 1,
            ),
          ),
      ],
    );
  }
}