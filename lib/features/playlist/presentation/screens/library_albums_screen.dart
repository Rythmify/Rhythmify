/// Library tab showing all collections with type == album.
/// Filters [playlistListProvider] by [PlaylistType.album] and supports live search.
/// Albums are created via Edit playlist → Convert to Album, not from this screen directly.
/// [_onConverted] handles post-conversion navigation to the correct Library tab.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_shared_widgets.dart';

/// Library → Albums.
/// Filtered list of all collections with type == album.
/// Layout matches the screenshot: centered AppBar title, search bar, list.
class LibraryAlbumsScreen extends ConsumerStatefulWidget {
  const LibraryAlbumsScreen({super.key});

  @override
  ConsumerState<LibraryAlbumsScreen> createState() =>
      _LibraryAlbumsScreenState();
}

class _LibraryAlbumsScreenState extends ConsumerState<LibraryAlbumsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistListProvider);
    final allAlbums = state.playlists
        .where((p) => p.type == PlaylistType.album)
        .toList();
    final filtered = allAlbums
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
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
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
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
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.tune, color: Colors.grey[400], size: 22),
              ],
            ),
          ),
          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No albums yet.\n\nOpen a playlist → ··· → Edit\n→ Convert to Album.'
                          : 'No results for "$_searchQuery"',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final album = filtered[index];
                      return _AlbumTile(
                        key: Key('library_album_tile_${album.id}'),
                        album: album,
                        onTap: () => context.push(
                          '/library/albums/${album.id}',
                          extra: true,
                        ),
                        onMoreTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => PlaylistOptionsSheet(
                            playlistId: album.id,
                            isOwner: true,
                            onConverted: (t) => _onConverted(context, t),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            PlaylistCoverImage(playlist: album, size: 65, borderRadius: 4),
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
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  // "2026 · Album" — exactly as in the screenshot
                  Text(
                    '${album.releaseYear ?? album.createdAt.year} · Album',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('album_tile_more_${album.id}'),
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}
