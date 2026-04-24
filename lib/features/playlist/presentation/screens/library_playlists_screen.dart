// lib/features/playlist/presentation/screens/library_playlists_screen.dart

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/time_ago.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import '../widgets/create_playlist_sheet.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_shared_widgets.dart';

// ── Filter enums ──────────────────────────────────────────────────────────
enum _SortOption { recentlyAdded, firstAdded, recentlyUpdated, playlistName }
enum _FilterOption { all, liked, owned }

extension _SortLabel on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.recentlyAdded: return 'Recently added';
      case _SortOption.firstAdded: return 'First added';
      case _SortOption.recentlyUpdated: return 'Recently updated';
      case _SortOption.playlistName: return 'Playlist name';
    }
  }
}

extension _FilterLabel on _FilterOption {
  String get label {
    switch (this) {
      case _FilterOption.all: return 'All playlists';
      case _FilterOption.liked: return 'Liked playlists';
      case _FilterOption.owned: return 'Owned playlists';
    }
  }
}

// ════════════════════════════════════════════════════════════════════════════
class LibraryPlaylistsScreen extends ConsumerStatefulWidget {
  const LibraryPlaylistsScreen({super.key});

  @override
  ConsumerState<LibraryPlaylistsScreen> createState() =>
      _LibraryPlaylistsScreenState();
}

class _LibraryPlaylistsScreenState
    extends ConsumerState<LibraryPlaylistsScreen> {
  String _searchQuery = '';
  _SortOption _sort = _SortOption.recentlyAdded;
  _FilterOption _filter = _FilterOption.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playlistListProvider.notifier).loadPlaylists();
    });
  }

  String _currentUserId() {
    final authState = ref.read(authProvider);
    return authState is AuthAuthenticated ? authState.user.id : '';
  }

  List<PlaylistEntity> _applySortAndFilter(List<PlaylistEntity> input) {
    var result = input.where((p) => p.type == PlaylistType.playlist).toList();

    if (_filter == _FilterOption.owned) {
      final uid = _currentUserId();
      result = result.where((p) => p.ownerId == uid).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result.where((p) =>
          p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    switch (_sort) {
      case _SortOption.recentlyAdded:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.firstAdded:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOption.recentlyUpdated:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.playlistName:
        result.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return result;
  }

  void _onFilterChanged(_FilterOption newFilter) {
    setState(() => _filter = newFilter);
    if (newFilter == _FilterOption.liked) {
      ref.read(playlistListProvider.notifier).loadLikedPlaylists();
    } else {
      ref.read(playlistListProvider.notifier).loadPlaylists();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistListProvider);
    final filtered = _applySortAndFilter(state.playlists);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 🔶 TOP BACKGROUND (Refined positioning to match small tilted layers)
          Positioned(
            top: -60,
            right: -80,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(0.45) // Steeper angle
                ..setEntry(0, 1, 0.2), // Skew to match the perspective
              child: Column(
                children: List.generate(12, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    width: 320, // Reduced width so it doesn't cross the whole screen
                    height: 80, // More compact height
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF7700).withOpacity(0.8),
                          const Color(0xFFFF7700).withOpacity(0.0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1.2), // Thin border
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Search ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left,
                            color: AppTheme.textPrimary),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            onChanged: (v) =>
                                setState(() => _searchQuery = v),
                            style: AppTheme.bodyNormal,
                            decoration: InputDecoration(
                              hintText:
                                  'Search ${state.playlists.length} playlists',
                              hintStyle: AppTheme.bodyMedium,
                              prefixIcon: Icon(Icons.search,
                                  color: AppTheme.textSecondary),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.tune,
                            color: (_sort != _SortOption.recentlyAdded ||
                                    _filter != _FilterOption.all)
                                ? AppTheme.primaryBrand
                                : AppTheme.textSecondary),
                        onPressed: () => _showFilterSheet(context),
                      ),
                    ],
                  ),
                ),

                // ── Title ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Playlists',
                        style: AppTheme.headlineLarge),
                  ),
                ),

                // ── Buttons ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Import not available yet')),
                            );
                          },
                          icon: Icon(Icons.download_outlined,
                              color: AppTheme.textPrimary),
                          label: Text('Import',
                              style: AppTheme.labelLarge),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.surface,
                            side: BorderSide(
                                color: AppTheme.lighterSurface),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _showCreateSheet(context),
                          icon: Icon(Icons.add,
                              color: AppTheme.textPrimary),
                          label: Text('Create',
                              style: AppTheme.labelLarge),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.surface,
                            side: BorderSide(
                                color: AppTheme.lighterSurface),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── List ────────────────────────────────
                Expanded(
                  child: state.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryBrand),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 140),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final playlist = filtered[index];
                            final isOwner =
                                playlist.ownerId ==
                                    _currentUserId();

                            return _PlaylistListTile(
                              playlist: playlist,
                              onTap: () => context.push(
                                '/library/playlists/${playlist.id}',
                                extra: isOwner,
                              ),
                              onMoreTap: () => _showOptions(
                                  context, playlist, isOwner),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (_) => const SizedBox(),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePlaylistSheet(
        onCreated: (id) =>
            context.push('/library/playlists/$id', extra: true),
      ),
    );
  }

  void _showOptions(
      BuildContext context, PlaylistEntity playlist, bool isOwner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaylistOptionsSheet(
          playlistId: playlist.id, isOwner: isOwner),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
class _PlaylistListTile extends StatelessWidget {
  const _PlaylistListTile({
    required this.playlist,
    required this.onTap,
    required this.onMoreTap,
  });

  final PlaylistEntity playlist;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            PlaylistCoverImage(
              playlist: playlist,
              size: 60,
              borderRadius: 0,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(playlist.name,
                      style: AppTheme.bodyNormal),
                  Text(playlist.ownerName,
                      style: AppTheme.artistTitle),
                  Text(
                    '${playlist.subtitleLine} · ${timeAgo(playlist.createdAt)}',
                    style: AppTheme.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert,
                  color: AppTheme.textSecondary),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}