// lib/features/playlist/presentation/screens/library_playlists_screen.dart
//
// CHANGES vs original:
//   + Filter dropdown — Sort section (Recently added / First added /
//     Recently updated / Playlist name) + Filter section (All / Liked / Owned)
//   + timeAgo shown on each tile's subtitle via createdAt
//   + Liked filter calls backend; Owned filters client-side

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/time_ago.dart';
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
      case _SortOption.recentlyAdded:    return 'Recently added';
      case _SortOption.firstAdded:       return 'First added';
      case _SortOption.recentlyUpdated:  return 'Recently updated';
      case _SortOption.playlistName:     return 'Playlist name';
    }
  }
}

extension _FilterLabel on _FilterOption {
  String get label {
    switch (this) {
      case _FilterOption.all:   return 'All playlists';
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
  _SortOption _sort   = _SortOption.recentlyAdded;
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

  // ── Apply sort ────────────────────────────────────────────────────────────
  List<PlaylistEntity> _applySortAndFilter(List<PlaylistEntity> input) {
    // 1. type filter (playlists only)
    var result = input.where((p) => p.type == PlaylistType.playlist).toList();

    // 2. ownership / liked filter (liked is handled by backend load,
    //    owned is filtered client-side)
    if (_filter == _FilterOption.owned) {
      final uid = _currentUserId();
      result = result.where((p) => p.ownerId == uid).toList();
    }

    // 3. search
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // 4. sort
    switch (_sort) {
      case _SortOption.recentlyAdded:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.firstAdded:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOption.recentlyUpdated:
        // createdAt is the best proxy we have without an updatedAt field
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.playlistName:
        result.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return result;
  }

  // ── Trigger the right backend call when filter changes ───────────────────
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
    final state    = ref.watch(playlistListProvider);
    final filtered = _applySortAndFilter(state.playlists);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('library_playlists_back_button'),
                    icon: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 26),
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
                            color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText:
                              'Search ${state.playlists.where((p) => p.type == PlaylistType.playlist).length} playlists',
                          hintStyle: TextStyle(
                              color: Colors.grey[600], fontSize: 14),
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.grey, size: 18),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ── Filter button ──────────────────────────────────
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Icon(
                      Icons.tune,
                      color: (_sort != _SortOption.recentlyAdded ||
                              _filter != _FilterOption.all)
                          ? const Color(0xFFFF5500)
                          : Colors.grey[400],
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // ── Title ───────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Playlists',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800),
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
                              content: Text('Import not available yet')),
                        );
                      },
                      icon: const Icon(Icons.download_outlined,
                          size: 18, color: Colors.white),
                      label: const Text('Import',
                          style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('library_playlists_create_button'),
                      onPressed: () => _showCreateSheet(context),
                      icon: const Icon(Icons.add,
                          size: 18, color: Colors.white),
                      label: const Text('Create',
                          style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Active filter chip (if not defaults) ─────────────────────
            if (_filter != _FilterOption.all ||
                _sort != _SortOption.recentlyAdded)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (_filter != _FilterOption.all)
                        _FilterChip(
                          label: _filter.label,
                          onRemove: () => _onFilterChanged(_FilterOption.all),
                        ),
                      if (_sort != _SortOption.recentlyAdded)
                        _FilterChip(
                          label: _sort.label,
                          onRemove: () =>
                              setState(() => _sort = _SortOption.recentlyAdded),
                        ),
                    ],
                  ),
                ),
              ),

            // ── Playlist list ────────────────────────────────────────────
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFFF5500)))
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
                      itemBuilder: (context, index) {
                        final playlist = filtered[index];
                        final isOwner =
                            playlist.ownerId == _currentUserId();
                        return _PlaylistListTile(
                          key: Key('library_playlist_tile_${playlist.id}'),
                          playlist: playlist,
                          onTap: () => context.push(
                            '/library/playlists/${playlist.id}',
                            extra: isOwner,
                          ),
                          onMoreTap: () =>
                              _showOptions(context, playlist, isOwner),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter bottom sheet ───────────────────────────────────────────────────
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (_) => _FilterSheet(
        currentSort: _sort,
        currentFilter: _filter,
        onSortChanged: (s) => setState(() => _sort = s),
        onFilterChanged: _onFilterChanged,
      ),
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
// Playlist list tile — shows timeAgo on createdAt
// ════════════════════════════════════════════════════════════════════════════
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
            PlaylistCoverImage(
                playlist: playlist, size: 60, borderRadius: 4),
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
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    playlist.ownerName,
                    style:
                        TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  // subtitleLine + timeAgo
                  Text(
                    '${playlist.subtitleLine} · ${timeAgo(playlist.createdAt)}',
                    style:
                        TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('playlist_tile_more_${playlist.id}'),
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

// ════════════════════════════════════════════════════════════════════════════
// Filter bottom sheet
// ════════════════════════════════════════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.currentSort,
    required this.currentFilter,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  final _SortOption currentSort;
  final _FilterOption currentFilter;
  final ValueChanged<_SortOption> onSortChanged;
  final ValueChanged<_FilterOption> onFilterChanged;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _SortOption _sort;
  late _FilterOption _filter;

  @override
  void initState() {
    super.initState();
    _sort   = widget.currentSort;
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BottomSheetHandle(),

          // ── Sort section ────────────────────────────────────────────
          ..._SortOption.values.map((s) => _SheetRow(
                label: s.label,
                selected: _sort == s,
                onTap: () {
                  setState(() => _sort = s);
                  widget.onSortChanged(s);
                },
              )),

          const Divider(color: Colors.white12, height: 1),

          // ── Filter section ──────────────────────────────────────────
          ..._FilterOption.values.map((f) => _SheetRow(
                label: f.label,
                selected: _filter == f,
                onTap: () {
                  setState(() => _filter = f);
                  widget.onFilterChanged(f);
                  Navigator.of(context).pop();
                },
              )),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey[400],
                  fontSize: 15,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Active filter chip
// ════════════════════════════════════════════════════════════════════════════
class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF5500), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close,
                color: Colors.white54, size: 14),
          ),
        ],
      ),
    );
  }
}