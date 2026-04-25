import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/core/presentation/widgets/cast_media_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../../profile/presentation/widgets/profile_avatar.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';
import '../../../player/presentation/providers/player_provider.dart';
import '../../../../core/domain/entities/track.dart';

/// The Library main screen — a navigation hub matching SoundCloud's layout.
///
/// Structure:
/// - "Transfer your gems" import banner card at the top (dismissible)
/// - Vertical [ListView] of menu items with chevrons
/// - "Recently played" horizontal row with "See All" button
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  bool _showBanner = true;

  void _dismissBanner() => setState(() => _showBanner = false);

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUserAvatar = authState is AuthAuthenticated
        ? authState.user.avatarUrl
        : null;
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Library'),
        centerTitle: false,
        actions: [
          TextButton(
            key: const Key('library_upgrade_pro_button'),
            onPressed: () => context.push('/upgrade'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryBrand,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Upgrade to Pro',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            key: const Key('library_cast_icon_button'),
            icon: const Icon(Icons.cast),
            onPressed: () => showCastMediaSheet(context, ref),
          ),
          IconButton(
            key: const Key('library_settings_icon_button'),
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/library/settings'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              key: const Key('library_profile_avatar_gesture_detector'),
              onTap: () => context.push('/profile/me'),
              child: ProfileAvatar(avatarUrl: currentUserAvatar, radius: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        key: const Key('library_main_scroll_view'),
        children: [
          if (_showBanner)
            Dismissible(
              key: const Key('library_import_banner_dismissible'),
              direction: DismissDirection.horizontal,
              onDismissed: (_) => _dismissBanner(),
              child: _ImportBannerCard(
                onImport: () =>
                    context.push('/library/settings/import-my-music'),
                onClose: _dismissBanner,
              ),
            ),

          if (_showBanner) const SizedBox(height: 8),

          _menuItem(
            context,
            label: 'Your likes',
            key: const Key('library_likes_item'),
            onTap: () => context.push('/library/likes'),
          ),
          _menuItem(
            context,
            label: 'Playlists',
            key: const Key('library_playlists_item'),
            onTap: () => context.push('/library/playlists'),
          ),
          _menuItem(
            context,
            label: 'Albums',
            key: const Key('library_albums_item'),
            onTap: () => context.pushNamed('library-albums'),
          ),
          _menuItem(
            context,
            label: 'Following',
            key: const Key('library_following_item'),
            onTap: () => context.push('/library/following'),
          ),
          _menuItem(
            context,
            label: 'Stations',
            key: const Key('library_stations_item'),
            onTap: () => context.pushNamed('library-stations'),
          ),
          _menuItem(
            context,
            label: 'Your insights',
            key: const Key('library_insights_item'),
            onTap: () => context.push('/library/insights'),
          ),
          _menuItem(
            context,
            label: 'Your uploads',
            key: const Key('library_uploads_item'),
            onTap: () => context.push('/library/uploads'),
          ),

          const SizedBox(height: 8),

          _RecentlyPlayedSection(
            entries: historyState.entries.take(10).toList(),
            onSeeAll: () => context.push('/library/history'),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    Key? key,
  }) {
    return Column(
      children: [
        ListTile(
          key: key,
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          title: Text(
            label,
            style: AppTheme.titleMedium.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondary,
          ),
        ),
        const Divider(
          color: AppTheme.surface,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}

// ── Import Banner Card ─────────────────────────────────────────────────────────

class _ImportBannerCard extends StatelessWidget {
  final VoidCallback onImport;
  final VoidCallback onClose;

  const _ImportBannerCard({required this.onImport, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        key: const Key('library_import_banner_card'),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A3E),
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.35,
                child: Icon(Icons.album, size: 100, color: Colors.blue[200]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      key: const Key('library_import_banner_close_gesture'),
                      onTap: onClose,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Transfer your gems',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Import your music from Spotify, Apple\nMusic and more in just 3 steps.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    key: const Key('library_import_now_button'),
                    onPressed: onImport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Import Now',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentlyPlayedSection extends StatelessWidget {
  final List<RecentlyPlayedEntry> entries;
  final VoidCallback onSeeAll;

  const _RecentlyPlayedSection({required this.entries, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Recently played',
                style: AppTheme.titleMedium.copyWith(fontSize: 17),
              ),
              const Spacer(),
              TextButton(
                key: const Key('library_recently_played_see_all_button'),
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
        // Horizontal list of recently played items
        SizedBox(
          height: 110,
          child: ListView.builder(
            key: const Key('library_recently_played_list_view'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _RecentlyPlayedItem(
                entry: entry,
                allEntries: entries,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentlyPlayedItem extends ConsumerWidget {
  final RecentlyPlayedEntry entry;
  final List<RecentlyPlayedEntry> allEntries;
  final int index;

  const _RecentlyPlayedItem({
    required this.entry,
    required this.allEntries,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Build Track from entry
    final track = Track(
      id: entry.trackId,
      userId: entry.userId,
      title: entry.title,
      artist: entry.artistName,
      audioUrl: entry.audioUrl ?? '',
      streamUrl: entry.streamUrl,
      duration: Duration(seconds: entry.durationSeconds),
      playCount: entry.playCount,
      isLiked: entry.isLiked,
      isArtistFollowed: entry.isArtistFollowed,
      createdAt: entry.playedAt,
      coverImage: entry.artworkUrl,
    );

    // Build all tracks for queue
    final allTracks = allEntries.map((e) {
      return Track(
        id: e.trackId,
        userId: e.userId,
        title: e.title,
        artist: e.artistName,
        audioUrl: e.audioUrl ?? '',
        streamUrl: e.streamUrl,
        duration: Duration(seconds: e.durationSeconds),
        playCount: e.playCount,
        isLiked: e.isLiked,
        isArtistFollowed: e.isArtistFollowed,
        createdAt: e.playedAt,
        coverImage: e.artworkUrl,
      );
    }).toList();

    return GestureDetector(
      key: Key('library_recently_played_item_${entry.trackId}_gesture'),
      onTap: () {
        ref
            .read(playerStateProvider.notifier)
            .loadAndPlayQueue(allTracks, initialIndex: index);
      },
      child: Container(
        width: 75,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: entry.artworkUrl != null
                  ? Image.network(
                      entry.artworkUrl!,
                      width: 75,
                      height: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (c, u, e) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 6),
            Text(
              entry.title,
              style: AppTheme.labelSmall.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 75,
    height: 75,
    color: AppTheme.surface,
    child: const Icon(Icons.music_note, color: AppTheme.textSecondary),
  );
}
