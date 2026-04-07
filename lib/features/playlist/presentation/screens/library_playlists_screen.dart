// lib/features/playlist/presentation/screens/library_playlists_screen.dart
//
// The Library "Playlists" tab — shown when user taps Playlists in Library.
// Uses GoRouter (context.push) for navigation, matching the rest of the app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import '../widgets/create_playlist_sheet.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_shared_widgets.dart';

class LibraryPlaylistsScreen extends ConsumerStatefulWidget {
  const LibraryPlaylistsScreen({super.key});

  @override
  ConsumerState<LibraryPlaylistsScreen> createState() =>
      _LibraryPlaylistsScreenState();
}

class _LibraryPlaylistsScreenState
    extends ConsumerState<LibraryPlaylistsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistListProvider);
    final filtered = state.playlists
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('library_playlists_back_button'),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        key: const Key('library_playlists_search_field'),
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Search ${state.playlists.length} playlists',
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
            // ── Title ───────────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Playlists',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            // ── Import / Create buttons ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('library_playlists_import_button'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Import not available yet'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.download_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Import',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('library_playlists_create_button'),
                      onPressed: () => _showCreateSheet(context),
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ── Playlist list ──────────────────────────────────────────────
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF5500),
                      ),
                    )
                  : filtered.isEmpty
                  ? Center(
                      child: Text(
                        _searchQuery.isEmpty
                            ? 'No playlists yet.\nTap Create to make one!'
                            : 'No results for "$_searchQuery"',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _PlaylistListTile(
                        key: Key('library_playlist_tile_${filtered[index].id}'),
                        playlist: filtered[index],
                        // Navigate to detail using GoRouter
                        onTap: () => context.push(
                          '/library/playlists/${filtered[index].id}',
                          extra: true, // isOwner = true for now
                        ),
                        onMoreTap: () =>
                            _showOptions(context, filtered[index].id),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePlaylistSheet(
        // After creating, navigate to the new playlist's detail page.
        onCreated: (id) => context.push('/library/playlists/$id', extra: true),
      ),
    );
  }

  void _showOptions(BuildContext context, String playlistId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          PlaylistOptionsSheet(playlistId: playlistId, isOwner: true),
    );
  }
}

// ── Playlist row tile ──────────────────────────────────────────────────────

class _PlaylistListTile extends StatelessWidget {
  const _PlaylistListTile({
    super.key,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            PlaylistCoverImage(playlist: playlist, size: 60, borderRadius: 4),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    playlist.ownerName,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    playlist.subtitleLine,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('playlist_tile_more_${playlist.id}'),
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}
