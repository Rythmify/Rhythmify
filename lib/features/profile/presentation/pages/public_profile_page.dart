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
import '../../../player/presentation/widgets/mini_player.dart';
import '../../../player/presentation/pages/full_player_page.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../playlist/domain/entities/playlist_entity.dart';


/// A full-screen profile page showing a user's public information and tracks.
///
/// Rendered as a root-level route (outside [StatefulShellRoute]), so
/// [MainAppScaffold] is not in the tree. The mini player and full player
/// are therefore embedded directly in this page via a [Stack] overlay,
/// mirroring the behaviour seen inside the library tab.
///
/// Use `key: ValueKey('public_profile_$userId')` at the call site to
/// prevent widget-tree reuse when navigating between different profiles.
class PublicProfilePage extends ConsumerStatefulWidget {
  /// The ID of the user whose profile to display, or `'me'` for the
  /// currently authenticated user.
  final String userId;

  /// Creates a [PublicProfilePage].
  const PublicProfilePage({super.key, required this.userId});

  @override
  ConsumerState<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends ConsumerState<PublicProfilePage> {
  final _scrollController = ScrollController();

  /// Controls the draggable player sheet — mirrors [MainAppScaffold].
  final _draggableController = DraggableScrollableController();

  bool _showIncompleteBanner = true;
  late String _resolvedUserId;

  // ── Player sheet constants (same values as MainAppScaffold) ─────────────
  static const double _navBarHeight = 0.0; // no nav bar on this page
  static const double _miniPlayerHeight = 65.0;
  static const double _maxSize = 1.0;

  double get _minSize {
    if (!context.mounted) return 0.08;
    final h = MediaQuery.of(context).size.height;
    return h > 0 ? _miniPlayerHeight / h : 0.08;
  }

  void _expandPlayer() {
    if (_draggableController.isAttached) {
      _draggableController.animateTo(
        _maxSize,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _collapsePlayer() {
    if (_draggableController.isAttached) {
      _draggableController.animateTo(
        _minSize,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    final authState = ref.read(authProvider);
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : null;

    _resolvedUserId =
        widget.userId == currentUserId || widget.userId == 'me'
            ? 'me'
            : widget.userId;

    Future.microtask(() async {
      // ── Guard: skip reload if this profile is already loaded ────────────
      // When navigating back from followers/following (root-level routes),
      // PublicProfilePage rebuilds and initState fires again. Without this
      // guard, loadProfile + loadPreviews would re-run on an already-correct
      // state, causing follower/following counts to appear doubled.
      final currentState = _resolvedUserId == 'me'
          ? ref.read(ownProfileProvider)
          : ref.read(publicProfileProvider(_resolvedUserId));

      if (currentState is ProfileLoaded) return;
      // ────────────────────────────────────────────────────────────────────

      if (_resolvedUserId == 'me') {
        await ref
            .read(ownProfileProvider.notifier)
            .loadProfile(userId: _resolvedUserId);
        if (mounted) {
          ref
              .read(ownProfileProvider.notifier)
              .loadPreviews(_resolvedUserId);
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
    _draggableController.dispose();
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
    final profileState = _resolvedUserId == 'me'
        ? ref.watch(ownProfileProvider)
        : ref.watch(publicProfileProvider(_resolvedUserId));

    final authState = ref.watch(authProvider);
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : null;
    final isOwnProfile =
        widget.userId == currentUserId || widget.userId == 'me';

    final playerState = ref.watch(playerStateProvider);
    final hasTrack = playerState.currentTrack != null;
    final screenHeight = MediaQuery.of(context).size.height;
    final currentMinSize = _minSize;

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
      body: Stack(
        children: [
          // ── Profile content ──────────────────────────────────────────────
          switch (profileState) {
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
            ProfileLoaded() => _buildLoaded(
              context,
              profileState,
              isOwnProfile,
              hasTrack,
            ),
            _ => const SizedBox.shrink(),
          },

          // ── Mini / Full player overlay (mirrors MainAppScaffold) ─────────
          if (hasTrack)
            DraggableScrollableSheet(
              key: const Key('profile_player_draggable_sheet'),
              controller: _draggableController,
              initialChildSize: currentMinSize,
              minChildSize: currentMinSize,
              maxChildSize: _maxSize,
              snap: true,
              builder: (context, scrollController) {
                return Container(
                  color: Colors.transparent,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      height: screenHeight,
                      child: AnimatedBuilder(
                        animation: _draggableController,
                        builder: (context, child) {
                          final extent = _draggableController.isAttached
                              ? _draggableController.size
                              : currentMinSize;
                          final t = ((extent - currentMinSize) /
                                  (_maxSize - currentMinSize))
                              .clamp(0.0, 1.0);

                          return Stack(
                            children: [
                              // Full player
                              Opacity(
                                opacity: t,
                                child: Container(
                                  color: Colors.black,
                                  child: IgnorePointer(
                                    ignoring: t < 0.5,
                                    child: FullPlayerPage(
                                      key: const Key(
                                        'profile_full_player_page',
                                      ),
                                      onCollapse: _collapsePlayer,
                                    ),
                                  ),
                                ),
                              ),

                              // Mini player
                              if (t < 0.5)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Opacity(
                                    opacity: (1 - t * 5).clamp(0.0, 1.0),
                                    child: MiniPlayer(
                                      key: const Key(
                                        'profile_mini_player_widget',
                                      ),
                                      onTap: _expandPlayer,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    ProfileLoaded state,
    bool isOwnProfile,
    bool hasTrack,
  ) {
    final hasAnyContent =
        state.uploadedTracks.isNotEmpty ||
        state.likedTracks.isNotEmpty ||
        state.repostedTracks.isNotEmpty ||
        state.playlists.isNotEmpty;

    // Extra bottom padding so last item clears the mini player
    final bottomPadding = hasTrack ? 80.0 : 0.0;

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
                ProfileAvatar(
                  avatarUrl: state.profile.avatarUrl,
                  radius: 60,
                ),
                const SizedBox(height: 12),
                Text(
                  state.profile.displayName,
                  style: AppTheme.headlineLarge,
                ),
                const SizedBox(height: 4),
                if (state.profile.city != null ||
                    state.profile.country != null)
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
                    key: const Key(
                      'public_profile_complete_data_dismissible',
                    ),
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
                  onFollowersTap: () => context.push(
                    '/profile/${state.profile.id}/followers',
                  ),
                  onFollowingTap: () => context.push(
                    '/profile/${state.profile.id}/following',
                  ),
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
                onSeeAll: () =>
                    context.push('/profile/$_resolvedUserId/likes'),
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
          if (state.playlists.isNotEmpty)
            SliverToBoxAdapter(
              child: _PlaylistsSection(
                title: 'Playlists',
                playlists: state.playlists.take(4).toList(),
                userId: _resolvedUserId,
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: 120 + bottomPadding),
          ),
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

// ── Profile section (tracks) ─────────────────────────────────────────────────

/// Displays a titled section of up to 3 tracks with a "See All" button.
///
/// Tapping a track starts playback from that index via [playerStateProvider].
class _ProfileSection extends ConsumerWidget {
  /// Section title shown above the track list (e.g. `'Uploads'`).
  final String title;

  /// Tracks to display — typically a `.take(3)` slice.
  final List<Track> tracks;

  /// Called when the user taps "See All".
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
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(fontSize: 22),
              ),
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
          final index = entry.key;
          final track = entry.value;
          return GestureDetector(
            key: Key('profile_${title}_${track.id}_gesture'),
            onTap: () {
              ref
                  .read(playerStateProvider.notifier)
                  .loadAndPlayQueue(tracks, initialIndex: index);
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

// ── Playlists section ─────────────────────────────────────────────────────────

/// Displays a titled section of playlists as a 2-column grid with a
/// "See All" button — matching the screenshot layout with large square
/// cover images, playlist name and owner name below each card.
class _PlaylistsSection extends ConsumerWidget {
  /// Section title (e.g. `'Playlists'`).
  final String title;

  /// Playlists to display — typically a `.take(4)` slice.
  final List<PlaylistEntity> playlists;

  /// Resolved user ID used for the "See All" navigation target.
  final String userId;

  const _PlaylistsSection({
    required this.title,
    required this.playlists,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(fontSize: 22),
              ),
              TextButton(
                onPressed: () => context.push('/library/playlists'),
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

        // ── 2-column grid ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: playlists.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              // Extra height below each cell for the text labels
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return GestureDetector(
                key: Key('profile_playlist_${playlist.id}_gesture'),
                onTap: () => context.push(
                  '/playlist/${playlist.id}',
                  extra: false,
                ),
                child: _PlaylistGridCard(
                  key: Key('playlist_grid_card_${playlist.id}'),
                  playlist: playlist,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),
        const Divider(color: AppTheme.surface, height: 1),
      ],
    );
  }
}

// ── Playlist grid card ────────────────────────────────────────────────────────

/// A card for use inside a 2-column grid: large square cover art with the
/// playlist name and owner name rendered below, matching the screenshot.
class _PlaylistGridCard extends StatelessWidget {
  /// The playlist to display.
  final PlaylistEntity playlist;

  const _PlaylistGridCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Square cover image ───────────────────────────────────────────
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: (playlist.coverUrl != null &&
                    playlist.coverUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: playlist.coverUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _coverPlaceholder(),
                    errorWidget: (_, __, ___) => _coverPlaceholder(),
                  )
                : _coverPlaceholder(),
          ),
        ),

        const SizedBox(height: 6),

        // ── Playlist name ────────────────────────────────────────────────
        Text(
          playlist.name,
          style: AppTheme.labelLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 2),

        // ── Owner name ───────────────────────────────────────────────────
        if (playlist.ownerName != null && playlist.ownerName!.isNotEmpty)
          Text(
            playlist.ownerName!,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _coverPlaceholder() => Container(
    color: Colors.grey[800],
    child: const Center(
      child: Icon(Icons.music_note, color: Colors.grey, size: 36),
    ),
  );
}

// ── Incomplete profile banner ─────────────────────────────────────────────────

/// A dismissible banner prompting the user to complete their profile.
class _IncompleteProfileBanner extends StatelessWidget {
  /// Called when the user taps the "Complete" button.
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
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
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