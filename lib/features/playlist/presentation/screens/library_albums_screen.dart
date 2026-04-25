// lib/features/playlist/presentation/screens/library_albums_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_shared_widgets.dart';

class LibraryAlbumsScreen extends ConsumerStatefulWidget {
  const LibraryAlbumsScreen({super.key});

  @override
  ConsumerState<LibraryAlbumsScreen> createState() =>
      _LibraryAlbumsScreenState();
}

class _LibraryAlbumsScreenState extends ConsumerState<LibraryAlbumsScreen> {
  String _searchQuery = '';
  bool _showLiked = false;

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

  void _onFilterChanged(bool liked) {
    setState(() => _showLiked = liked);
    if (liked) {
      ref.read(playlistListProvider.notifier).loadLikedAlbums();
    } else {
      ref.read(playlistListProvider.notifier).loadPlaylists();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistListProvider);
    final allAlbums = state.playlists
        .where((p) => p.type == PlaylistType.album)
        .toList();
    final filtered = allAlbums
        .where((p) =>
            p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          key: const Key('library_albums_back_button'),
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Albums',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                key: const Key('library_albums_search_field'),
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                      'Search ${allAlbums.length} album${allAlbums.length == 1 ? '' : 's'}',
                  hintStyle:
                      TextStyle(color: Colors.grey[600], fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.grey, size: 18),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // ── My Albums / Liked toggle ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'My Albums',
                  selected: !_showLiked,
                  onTap: () => _onFilterChanged(false),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Liked',
                  selected: _showLiked,
                  onTap: () => _onFilterChanged(true),
                ),
              ],
            ),
          ),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: state.isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: Color(0xFFFF5500)),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Text(
                          _showLiked
                              ? 'No liked albums yet.\n\nLike an album to see it here.'
                              : _searchQuery.isEmpty
                                  ? 'No albums yet.\n\nOpen a playlist → ··· → Edit\n→ Convert to Album.'
                                  : 'No results for "$_searchQuery"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey[500], fontSize: 14),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 140),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final album = filtered[index];
                          final isOwner =
                              album.ownerId == _currentUserId();
                          return _AlbumTile(
                            key: Key('library_album_tile_${album.id}'),
                            album: album,
                            onTap: () => context.push(
                              '/playlist/${album.id}', // ✅ FIXED: was /library/albums/
                              extra: isOwner,
                            ),
                            onMoreTap: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => PlaylistOptionsSheet(
                                playlistId: album.id,
                                isOwner: isOwner,
                                onConverted: (t) =>
                                    _onConverted(context, t),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _onConverted(BuildContext context, PlaylistType t) {
    switch (t) {
      case PlaylistType.playlist:
        context.go('/library/playlists');
      case PlaylistType.station:
        context.go('/library/stations');
      case PlaylistType.album:
        break;
    }
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color:
              selected ? AppTheme.primaryBrand : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primaryBrand
                : AppTheme.lighterSurface,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: selected
                ? Colors.white
                : AppTheme.textSecondary,
            fontWeight: selected
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Album tile ────────────────────────────────────────────────────────────────
class _AlbumTile extends StatelessWidget {
  const _AlbumTile({
    super.key,
    required this.album,
    required this.onTap,
    required this.onMoreTap,
  });

  final PlaylistEntity album;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            PlaylistCoverImage(
              playlist: album,
              size: 65,
              borderRadius: 0,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    album.ownerName,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${album.releaseYear ?? album.createdAt.year} · Album',
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('album_tile_more_${album.id}'),
              icon: const Icon(Icons.more_vert,
                  color: Colors.grey, size: 20),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}