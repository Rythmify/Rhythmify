// lib/features/playlist/presentation/screens/library_playlists_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';
import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import '../widgets/create_playlist_sheet.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_shared_widgets.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────
enum _SortOption { recentlyAdded, firstAdded, recentlyUpdated, playlistName }

enum _FilterOption { all, liked, owned }

// ═════════════════════════════════════════════════════════════════════════════
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

  // Merged list: created + liked (deduped by id) for "All playlists"
  final List<PlaylistEntity> _allPlaylists = [];
  final List<PlaylistEntity> _likedPlaylists = [];
  bool _loading = true;

  // For the overlay filter dropdown
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

  // Load created playlists AND liked playlists, merge for "All"
  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final notifier = ref.read(playlistListProvider.notifier);

    // Load created
    await notifier.loadPlaylists();
    final created = ref.read(playlistListProvider).playlists;

    // Load liked
    await notifier.loadLikedPlaylists();
    final liked = ref.read(playlistListProvider).playlists;

    // Merge: start with created, add liked items not already in created
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

    // Restore provider to created state so the list screen shows correctly
    await notifier.loadPlaylists();
  }

  Future<void> _loadForFilter() async {
    setState(() => _loading = true);
    if (_filter == _FilterOption.liked) {
      final notifier = ref.read(playlistListProvider.notifier);
      await notifier.loadLikedPlaylists();
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

  String _currentUserId() {
    final authState = ref.read(authProvider);
    return authState is AuthAuthenticated ? authState.user.id : '';
  }

  List<PlaylistEntity> get _sourceList {
    switch (_filter) {
      case _FilterOption.all:
        return _allPlaylists;
      case _FilterOption.liked:
        return _likedPlaylists;
      case _FilterOption.owned:
        final uid = _currentUserId();
        return _allPlaylists.where((p) => p.ownerId == uid).toList();
    }
  }

  List<PlaylistEntity> _applySortAndSearch(List<PlaylistEntity> input) {
    var result = input
        .where((p) =>
            _filter == _FilterOption.liked ||
            p.type == PlaylistType.playlist)
        .toList();

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
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
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return result;
  }

  // ── Overlay filter dropdown ───────────────────────────────────────────────

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
        // Tap outside → close
        behavior: HitTestBehavior.translucent,
        onTap: _removeOverlay,
        child: Stack(
          children: [
            Positioned(
              // Position card so its top-right aligns with the filter icon
              top: offset.dy + size.height + 4,
              right: MediaQuery.of(context).size.width -
                  offset.dx -
                  size.width,
              child: GestureDetector(
                onTap: () {}, // prevent tap-through to the dismiss gesture
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
          // ── Decorative background ────────────────────────────────
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
                // ── Search row ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left,
                            color: AppTheme.textPrimary),
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
                            onChanged: (v) =>
                                setState(() => _searchQuery = v),
                            style: AppTheme.bodyNormal,
                            decoration: InputDecoration(
                              hintText: 'Search $totalCount playlists',
                              hintStyle: AppTheme.bodyMedium,
                              prefixIcon: const Icon(Icons.search,
                                  color: AppTheme.textSecondary),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      // "Cancel" text button (matches SoundCloud)
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Cancel',
                          style: AppTheme.bodyNormal.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      // Filter icon with overlay key
                      IconButton(
                        key: _filterIconKey,
                        icon: Icon(
                          Icons.tune,
                          color: (_sort != _SortOption.recentlyAdded ||
                                  _filter != _FilterOption.all)
                              ? AppTheme.primaryBrand
                              : AppTheme.textSecondary,
                        ),
                        onPressed: _toggleOverlay,
                      ),
                    ],
                  ),
                ),

                // ── Title ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Playlists', style: AppTheme.headlineLarge),
                  ),
                ),

                // ── Import + Create buttons ─────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Import not available yet'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.download_outlined,
                              color: AppTheme.textPrimary),
                          label:
                              Text('Import', style: AppTheme.labelLarge),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.surface,
                            side: const BorderSide(
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
                          onPressed: () => _showCreateSheet(context),
                          icon: const Icon(Icons.add,
                              color: AppTheme.textPrimary),
                          label:
                              Text('Create', style: AppTheme.labelLarge),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppTheme.surface,
                            side: const BorderSide(
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

                // ── List ───────────────────────────────────────────
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryBrand),
                        )
                      : filtered.isEmpty
                          ? _emptyState()
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.only(bottom: 140),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final playlist = filtered[index];
                                final isOwner =
                                    playlist.ownerId == _currentUserId();
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
        child: Text(message,
            style: AppTheme.bodyMedium, textAlign: TextAlign.center),
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
      builder: (_) =>
          PlaylistOptionsSheet(playlistId: playlist.id, isOwner: isOwner),
    );
  }
}

// ── Filter dropdown widget ────────────────────────────────────────────────────
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
            // Sort group
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
            // Divider between the two groups
            const Divider(
                height: 1, thickness: 1, color: Color(0xFF3A3A3A)),
            // Filter group
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
            // Checkmark on the LEFT (matches SoundCloud screenshot exactly)
            SizedBox(
              width: 20,
              child: checked
                  ? const Icon(Icons.check,
                      color: AppTheme.textPrimary, size: 16)
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
                  fontWeight:
                      checked ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Playlist list tile ────────────────────────────────────────────────────────
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            PlaylistCoverImage(
                playlist: playlist, size: 60, borderRadius: 0),
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
                    playlist.ownerName.isNotEmpty
                        ? playlist.ownerName
                        : 'You',
                    style: AppTheme.artistTitle,
                  ),
                  Text(
                    playlist.subtitleLine,
                    style: AppTheme.labelSmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.more_vert,
                  color: AppTheme.textSecondary),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}