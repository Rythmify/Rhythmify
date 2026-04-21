// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rythmify/core/presentation/widgets/cast_media_sheet.dart';
import '../../../../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/share_bottom_sheet.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../../track/presentation/widgets/track_card.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../../core/domain/entities/track.dart';

/// A full-screen profile page showing a user's public information and tracks.
///
/// Uses [publicProfileProvider] for other users and [ownProfileProvider] for
/// the authenticated user to prevent state flicker when navigating.
///
/// Add `key: ValueKey('public_profile_${userId}')` to prevent widget tree reuse
/// and ensure a fresh state when switching between profiles.
class PublicProfilePage extends ConsumerStatefulWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  ConsumerState<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends ConsumerState<PublicProfilePage> {
  final _scrollController = ScrollController();
  bool _showIncompleteBanner = true;
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

    Future.microtask(() async {
      /// Load profile using the appropriate provider based on whether it's own or public profile
      if (_resolvedUserId == 'me') {
        await ref
            .read(ownProfileProvider.notifier)
            .loadProfile(userId: _resolvedUserId);
        if (mounted) {
          ref.read(ownProfileProvider.notifier).loadPreviews(_resolvedUserId);
        }
      } else {
        await ref
            .read(publicProfileProvider(_resolvedUserId).notifier)
            .loadProfile(userId: _resolvedUserId);
        if (mounted) {
          ref
              .read(publicProfileProvider(_resolvedUserId).notifier)
              .loadPreviews(_resolvedUserId);
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
    /// Read the appropriate provider based on whether it's own or public profile
    final profileState = _resolvedUserId == 'me'
        ? ref.watch(ownProfileProvider)
        : ref.watch(publicProfileProvider(_resolvedUserId));

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
            onPressed: () => showCastMediaSheet(context, ref),
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
                onPressed: () {
                  final notifier = _resolvedUserId == 'me'
                      ? ref.read(ownProfileProvider.notifier)
                      : ref.read(
                          publicProfileProvider(_resolvedUserId).notifier,
                        );
                  notifier.loadProfile(userId: _resolvedUserId);
                },
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

  Widget _buildLoaded(
    BuildContext context,
    ProfileLoaded state,
    bool isOwnProfile,
  ) {
    final hasAnyContent =
        state.uploadedTracks.isNotEmpty ||
        state.likedTracks.isNotEmpty ||
        state.repostedTracks.isNotEmpty;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoverPhoto(state.profile.coverUrl),
                const SizedBox(height: 12),
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
                if (isOwnProfile &&
                    _showIncompleteBanner &&
                    _isProfileIncomplete(state.profile)) ...[
                  const SizedBox(height: 12),
                  Dismissible(
                    key: const Key('public_profile_complete_data_dismissible'),
                    direction: DismissDirection.horizontal,
                    onDismissed: (_) =>
                        setState(() => _showIncompleteBanner = false),
                    child: _IncompleteProfileBanner(
                      onEdit: () => context.push('/profile/edit'),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                ProfileStatsRow(
                  followersCount: state.profile.followersCount,
                  followingCount: state.profile.followingCount,
                  onFollowersTap: () =>
                      context.push('/profile/${state.profile.id}/followers'),
                  onFollowingTap: () =>
                      context.push('/profile/${state.profile.id}/following'),
                ),
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
                          final notifier = _resolvedUserId == 'me'
                              ? ref.read(ownProfileProvider.notifier)
                              : ref.read(
                                  publicProfileProvider(
                                    _resolvedUserId,
                                  ).notifier,
                                );

                          if (state.profile.isFollowing) {
                            notifier.unfollowUser(userId: widget.userId);
                          } else {
                            notifier.followUser(userId: widget.userId);
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

        if (!hasAnyContent)
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
        else ...[
          if (state.uploadedTracks.isNotEmpty)
            SliverToBoxAdapter(
              child: _ProfileSection(
                title: 'Uploads',
                tracks: state.uploadedTracks.take(3).toList(),
                onSeeAll: () =>
                    context.push('/profile/$_resolvedUserId/uploads'),
              ),
            ),
          if (state.likedTracks.isNotEmpty)
            SliverToBoxAdapter(
              child: _ProfileSection(
                title: 'Likes',
                tracks: state.likedTracks.take(3).toList(),
                onSeeAll: () => context.push('/profile/$_resolvedUserId/likes'),
              ),
            ),
          if (state.repostedTracks.isNotEmpty)
            SliverToBoxAdapter(
              child: _ProfileSection(
                title: 'Reposts',
                tracks: state.repostedTracks.take(3).toList(),
                onSeeAll: () =>
                    context.push('/profile/$_resolvedUserId/reposts'),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ],
    );
  }

  Widget _buildCoverPhoto(String? coverUrl) {
    final hasCover = coverUrl != null && coverUrl.trim().isNotEmpty;
    if (!hasCover) {
      return Container(
        key: const Key('public_profile_cover_empty_container'),
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        key: const Key('public_profile_cover_image'),
        imageUrl: coverUrl,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(
          color: AppTheme.surface,
          height: 150,
          width: double.infinity,
        ),
        errorWidget: (_, _, _) => Container(
          key: const Key('public_profile_cover_error_container'),
          color: AppTheme.surface,
          height: 150,
          width: double.infinity,
        ),
      ),
    );
  }

  bool _isProfileIncomplete(ProfileEntity profile) {
    bool isBlank(String? value) => value == null || value.trim().isEmpty;
    return isBlank(profile.username) ||
        isBlank(profile.avatarUrl) ||
        isBlank(profile.coverUrl) ||
        isBlank(profile.city) ||
        isBlank(profile.country) ||
        isBlank(profile.bio);
  }
}

/// Displays a section of tracks (e.g., "Uploads", "Likes", "Reposts").
///
/// When a track is tapped, triggers playback via [playerStateProvider.notifier].
/// The mini player is a persistent overlay and appears automatically when
/// playback starts.
class _ProfileSection extends ConsumerWidget {
  /// The title of this section (e.g., "Uploads").
  final String title;

  /// The list of [Track]s to display.
  final List<Track> tracks;

  /// Callback when "See All" is tapped.
  final VoidCallback onSeeAll;

  const _ProfileSection({
    required this.title,
    required this.tracks,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTheme.titleMedium.copyWith(fontSize: 22)),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See All',
                  style: AppTheme.labelLarge.copyWith(
                    color: AppTheme.primaryBrand,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...tracks.asMap().entries.map((entry) {
          final int index = entry.key;
          final Track track = entry.value;

          return GestureDetector(
            key: Key('profile_${title}_${track.id}_gesture'),
            onTap: () {
              /// Trigger playback for this track and all subsequent tracks in the list
              ref
                  .read(playerStateProvider.notifier)
                  .loadAndPlayQueue(tracks, initialIndex: index);

              /// The mini player is a persistent overlay and appears automatically
            },
            child: TrackCard(
              key: Key('profile_${title}_${track.id}'),
              track: track,
            ),
          );
        }),
        const SizedBox(height: 12),
        const Divider(color: AppTheme.surface, height: 1),
      ],
    );
  }
}

class _IncompleteProfileBanner extends StatelessWidget {
  final VoidCallback onEdit;

  const _IncompleteProfileBanner({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('public_profile_complete_data_banner'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A3E),
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Complete your profile data to unlock a better experience.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            key: const Key('public_profile_complete_data_button'),
            onPressed: onEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 0,
            ),
            child: const Text(
              'Complete',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
