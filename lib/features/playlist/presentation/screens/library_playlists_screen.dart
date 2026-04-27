// lib/features/playlist/presentation/screens/library_playlists_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../data/local/local_saved_store.dart';
import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import '../widgets/create_playlist_sheet.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_shared_widgets.dart';

enum _SortOption { recentlyAdded, firstAdded, recentlyUpdated, playlistName }

enum _FilterOption { all, liked, owned }

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

  final List<PlaylistEntity> _allPlaylists = [];
  final List<PlaylistEntity> _likedPlaylists = [];
  Set<String> _savedMixIds = {};
  Set<String> _savedTrackRadioPlaylistIds = {};
  bool _loading = true;

  OverlayEntry? _overlayEntry;
  final _filterIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  String _currentUserId() {
    final authState = ref.read(authProvider);
    return authState is AuthAuthenticated ? authState.user.id : '';
  }
// Replace _isPlaylistOwned in library_playlists_screen.dart with this:

  bool _isPlaylistOwned(PlaylistEntity playlist) {
    // Track radios and generated mixes are NEVER owned even if ownerId matches.
    // The backend creates them on behalf of the user but they are not editable
    // user playlists — they have their own routing and UI.
    if (playlist.isTrackRadio) return false;
    if (playlist.isGeneratedMix) return false;

    // isOwned flag set by fromJsonListOwned (filter=created endpoint)
    if (playlist.isOwned) return true;

    // Fallback: ownerId comparison for edge cases
    final uid = _currentUserId();
    return uid.isNotEmpty && playlist.ownerId == uid;
  }

  // Replace _loadAll in library_playlists_screen.dart with this simplified version.
  // Also remove the _savedMixIds and _savedTrackRadioPlaylistIds field declarations.

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final notifier = ref.read(playlistListProvider.notifier);

    await notifier.loadPlaylists();
    final created = ref.read(playlistListProvider).playlists;

    await notifier.loadLikedPlaylists();
    final liked = ref.read(playlistListProvider).playlists;

    final createdIds = created.map((p) => p.id).toSet();
    final merged = [
      ...created,
      ...liked.where((p) => !createdIds.contains(p.id)),
    ];

    if (mounted) {
      setState(() {
        _allPlaylists
          ..clear()
          ..addAll(merged);
        _likedPlaylists
          ..clear()
          ..addAll(liked);
        _loading = false;
      });
    }

    await notifier.loadPlaylists();
  }

  // Also remove these two field declarations from the class:
  //   Set<String> _savedMixIds = {};
  //   Set<String> _savedTrackRadioPlaylistIds = {};
  // And remove the LocalSavedStore import if no longer used elsewhere.

  // ADD THIS METHOD to _LibraryPlaylistsScreenState
  // Place it directly after _loadAll() — before get _sourceList

  Future<void> _loadForFilter() async {
    setState(() => _loading = true);
    if (_filter == _FilterOption.liked) {
      await ref.read(playlistListProvider.notifier).loadLikedPlaylists();
      final liked = ref.read(playlistListProvider).playlists;
      if (mounted) {
        setState(() {
          _likedPlaylists
            ..clear()
            ..addAll(liked);
          _loading = false;
        });
      }
    } else {
      await _loadAll();
    }
  }

  List<PlaylistEntity> get _sourceList {
    switch (_filter) {
      case _FilterOption.all:
        return _allPlaylists;
      case _FilterOption.liked:
        return _likedPlaylists;
      case _FilterOption.owned:
        return _allPlaylists.where(_isPlaylistOwned).toList();
    }
  }

  List<PlaylistEntity> _applySortAndSearch(List<PlaylistEntity> input) {
    var result = input
        .where(
          (p) =>
              _filter == _FilterOption.liked || p.type == PlaylistType.playlist,
        )
        .toList();

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    switch (_sort) {
      case _SortOption.recentlyAdded:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.firstAdded:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _SortOption.recentlyUpdated:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _SortOption.playlistName:
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }

    return result;
  }
  // Replace _onPlaylistTap in library_playlists_screen.dart with this:

  void _onPlaylistTap(BuildContext context, PlaylistEntity playlist) {
    // ── 1. OWNED playlist → full edit screen with suggestions ─────────────
    if (_isPlaylistOwned(playlist)) {
      context.push('/library/playlists/${playlist.id}', extra: true);
      return;
    }

    // ── 2. GENERATED MIX (auto_generated, curated, genre_trending) ────────
    // Routed to MixDetailScreen which calls GET /home/mixes/:id
    if (playlist.isGeneratedMix) {
      context.push(
        '/home/mix/${playlist.id}',
        extra: {
          'title': playlist.name,
          'ownerName': playlist.ownerName.isNotEmpty
              ? playlist.ownerName
              : 'You',
          'coverUrl': playlist.coverUrl,
          'trackCount': playlist.trackCount,
          'mixType': 'genre',
        },
      );
      return;
    }

    // ── 3. TRACK RADIO (track_radio subtype) ──────────────────────────────
    // Routed to PlaylistDetailScreen as non-owner — fetches via
    // GET /playlists/:id/tracks (works for track_radio on the backend)
    if (playlist.isTrackRadio) {
      context.push('/home/playlist/${playlist.id}', extra: false);
      return;
    }

    // ── 4. REGULAR liked playlist from another user ───────────────────────
    context.push('/home/playlist/${playlist.id}', extra: false);
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    final renderBox =
        _filterIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned(
              top: offset.dy + size.height + 4,
              right: MediaQuery.of(context).size.width - offset.dx - size.width,
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  color: Colors.transparent,
                  child: _FilterDropdown(
                    sort: _sort,
                    filter: _filter,
                    onSortChanged: (s) {
                      setState(() => _sort = s);
                      _removeOverlay();
                    },
                    onFilterChanged: (f) {
                      setState(() => _filter = f);
                      _removeOverlay();
                      _loadForFilter();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _applySortAndSearch(_sourceList);
    final totalCount = _allPlaylists.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // ── Decorative orange background ─────────────────────────
          Positioned(
            top: -60,
            right: -80,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateZ(0.45)
                ..setEntry(0, 1, 0.2),
              child: Column(
                children: List.generate(12, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    width: 320,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF7700).withValues(alpha: 0.8),
                          const Color(0xFFFF7700).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(1.2),
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
                // ── Search row ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                  child: Row(
                    children: [
                      IconButton(
                        key: const Key('library_playlists_back_button'),
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppTheme.textPrimary,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            key: const Key('library_playlists_search_field'),
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: AppTheme.bodyNormal,
                            decoration: InputDecoration(
                              hintText: 'Search $totalCount playlists',
                              hintStyle: AppTheme.bodyMedium,
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppTheme.textSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        key: const Key('library_playlists_cancel_button'),
                        onPressed: () => context.pop(),
                        child: Text(
                          'Cancel',
                          style: AppTheme.bodyNormal.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        key: _filterIconKey,
                        icon: Icon(
                          Icons.tune,
                          color:
                              (_sort != _SortOption.recentlyAdded ||
                                  _filter != _FilterOption.all)
                              ? AppTheme.primaryBrand
                              : AppTheme.textSecondary,
                        ),
                        onPressed: _toggleOverlay,
                      ),
                    ],
                  ),
                ),

                // ── Title ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Playlists', style: AppTheme.headlineLarge),
                  ),
                ),

                // ── Import + Create ───────────────────────────────
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
                            color: AppTheme.textPrimary,
                          ),
                          label: Text('Import', style: AppTheme.labelLarge),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.surface,
                            side: const BorderSide(
                              color: AppTheme.lighterSurface,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                            color: AppTheme.textPrimary,
                          ),
                          label: Text('Create', style: AppTheme.labelLarge),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.surface,
                            side: const BorderSide(
                              color: AppTheme.lighterSurface,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── List ─────────────────────────────────────────
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            key: Key('library_playlists_loading_indicator'),
                            color: AppTheme.primaryBrand,
                          ),
                        )
                      : filtered.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                          key: const Key('library_playlists_list'),
                          padding: const EdgeInsets.only(bottom: 140),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final playlist = filtered[index];
                            final isOwner = _isPlaylistOwned(playlist);
                            return _PlaylistListTile(
                              key: Key('playlist_tile_${playlist.id}'),
                              playlist: playlist,
                              onTap: () => _onPlaylistTap(context, playlist),
                              onMoreTap: () =>
                                  _showOptions(context, playlist, isOwner),
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

  Widget _emptyState() {
    final message = switch (_filter) {
      _FilterOption.liked =>
        'No liked playlists yet\nLike a mix or playlist to save it here',
      _FilterOption.owned => 'No playlists created yet',
      _FilterOption.all => 'No playlists yet',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          style: AppTheme.bodyMedium,
          textAlign: TextAlign.center,
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
        onCreated: (id) => context.push('/library/playlists/$id', extra: true),
      ),
    );
  }

  void _showOptions(
    BuildContext context,
    PlaylistEntity playlist,
    bool isOwner,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          PlaylistOptionsSheet(playlistId: playlist.id, isOwner: isOwner),
    );
  }
}

// ── Filter dropdown ───────────────────────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.sort,
    required this.filter,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  final _SortOption sort;
  final _FilterOption filter;
  final ValueChanged<_SortOption> onSortChanged;
  final ValueChanged<_FilterOption> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DropdownItem(
              label: 'Recently added',
              checked: sort == _SortOption.recentlyAdded,
              onTap: () => onSortChanged(_SortOption.recentlyAdded),
            ),
            _DropdownItem(
              label: 'First added',
              checked: sort == _SortOption.firstAdded,
              onTap: () => onSortChanged(_SortOption.firstAdded),
            ),
            _DropdownItem(
              label: 'Recently updated',
              checked: sort == _SortOption.recentlyUpdated,
              onTap: () => onSortChanged(_SortOption.recentlyUpdated),
            ),
            _DropdownItem(
              label: 'Playlist name',
              checked: sort == _SortOption.playlistName,
              onTap: () => onSortChanged(_SortOption.playlistName),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFF3A3A3A)),
            _DropdownItem(
              label: 'All playlists',
              checked: filter == _FilterOption.all,
              onTap: () => onFilterChanged(_FilterOption.all),
            ),
            _DropdownItem(
              label: 'Liked playlists',
              checked: filter == _FilterOption.liked,
              onTap: () => onFilterChanged(_FilterOption.liked),
            ),
            _DropdownItem(
              label: 'Owned playlists',
              checked: filter == _FilterOption.owned,
              onTap: () => onFilterChanged(_FilterOption.owned),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  const _DropdownItem({
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: checked
                  ? const Icon(
                      Icons.check,
                      color: AppTheme.textPrimary,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: checked
                      ? AppTheme.textPrimary
                      : AppTheme.textSecondary,
                  fontSize: 15,
                  fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Playlist tile ─────────────────────────────────────────────────────────────
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
            PlaylistCoverImage(playlist: playlist, size: 60, borderRadius: 0),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: AppTheme.bodyNormal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    playlist.ownerName.isNotEmpty ? playlist.ownerName : 'You',
                    style: AppTheme.artistTitle,
                  ),
                  Text(playlist.subtitleLine, style: AppTheme.labelSmall),
                ],
              ),
            ),
            IconButton(
              key: Key('playlist_tile_more_${playlist.id}'),
              icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}
