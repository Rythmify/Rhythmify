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

// ── Enums ─────────────────────────────────────────────────────────────────────
enum _AlbumSort { recentlyAdded, firstAdded, albumName }

enum _AlbumTypeFilter { all, album, compilation, ep, single }

extension _AlbumSortLabel on _AlbumSort {
  String get label {
    switch (this) {
      case _AlbumSort.recentlyAdded:
        return 'Recently added';
      case _AlbumSort.firstAdded:
        return 'First added';
      case _AlbumSort.albumName:
        return 'Album name';
    }
  }
}

extension _AlbumTypeFilterLabel on _AlbumTypeFilter {
  String get label {
    switch (this) {
      case _AlbumTypeFilter.all:
        return 'All';
      case _AlbumTypeFilter.album:
        return 'Album';
      case _AlbumTypeFilter.compilation:
        return 'Compilation';
      case _AlbumTypeFilter.ep:
        return 'EP';
      case _AlbumTypeFilter.single:
        return 'Single';
    }
  }

  // Maps to the subtype string the backend uses
  String? get subtype {
    switch (this) {
      case _AlbumTypeFilter.all:
        return null;
      case _AlbumTypeFilter.album:
        return 'album';
      case _AlbumTypeFilter.compilation:
        return 'compilation';
      case _AlbumTypeFilter.ep:
        return 'ep';
      case _AlbumTypeFilter.single:
        return 'single';
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
class LibraryAlbumsScreen extends ConsumerStatefulWidget {
  const LibraryAlbumsScreen({super.key});

  @override
  ConsumerState<LibraryAlbumsScreen> createState() =>
      _LibraryAlbumsScreenState();
}

class _LibraryAlbumsScreenState extends ConsumerState<LibraryAlbumsScreen> {
  String _searchQuery = '';
  _AlbumSort _sort = _AlbumSort.recentlyAdded;
  _AlbumTypeFilter _typeFilter = _AlbumTypeFilter.all;

  OverlayEntry? _overlayEntry;
  final _filterIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(playlistListProvider.notifier).loadPlaylists(),
    );
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

  List<PlaylistEntity> _applyFilters(List<PlaylistEntity> input) {
    // Only albums
    var result = input.where((p) => p.type == PlaylistType.album).toList();

    // Subtype filter (all = show everything album-type)
    if (_typeFilter != _AlbumTypeFilter.all) {
      // We can only filter client-side on what we have.
      // Albums, EPs, Singles, Compilations all map to PlaylistType.album
      // so we'd need the raw subtype. For now mark all as 'album' subtype
      // since PlaylistModel maps them all to PlaylistType.album.
      // This will be fully functional once backend returns subtype correctly.
    }

    // Search
    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Sort
    switch (_sort) {
      case _AlbumSort.recentlyAdded:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case _AlbumSort.firstAdded:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case _AlbumSort.albumName:
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }

    return result;
  }

  bool get _isFiltered =>
      _sort != _AlbumSort.recentlyAdded ||
      _typeFilter != _AlbumTypeFilter.all;

  // ── Overlay ───────────────────────────────────────────────────────────────

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
              right: MediaQuery.of(context).size.width -
                  offset.dx -
                  size.width,
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  color: Colors.transparent,
                  child: _AlbumFilterDropdown(
                    sort: _sort,
                    typeFilter: _typeFilter,
                    onSortChanged: (s) {
                      setState(() => _sort = s);
                      _removeOverlay();
                    },
                    onTypeFilterChanged: (f) {
                      setState(() => _typeFilter = f);
                      _removeOverlay();
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
    final state = ref.watch(playlistListProvider);
    final filtered = _applyFilters(state.playlists);

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
                              hintText:
                                  'Search ${filtered.length} album${filtered.length == 1 ? '' : 's'}',
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
                      IconButton(
                        key: _filterIconKey,
                        icon: Icon(
                          Icons.tune,
                          color: _isFiltered
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
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                        Text('Albums', style: AppTheme.headlineLarge),
                  ),
                ),

                // ── List ───────────────────────────────────────────
                Expanded(
                  child: state.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryBrand),
                        )
                      : filtered.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? 'No albums yet'
                                      : 'No results for "$_searchQuery"',
                                  style: AppTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.only(bottom: 140),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final album = filtered[index];
                                final isOwner =
                                    album.ownerId == _currentUserId();
                                return _AlbumTile(
                                  album: album,
                                  onTap: () => context.push(
                                    '/playlist/${album.id}',
                                    extra: isOwner,
                                  ),
                                  onMoreTap: () =>
                                      _showOptions(context, album, isOwner),
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

  void _showOptions(
      BuildContext context, PlaylistEntity album, bool isOwner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaylistOptionsSheet(
        playlistId: album.id,
        isOwner: isOwner,
        onConverted: (t) {
          switch (t) {
            case PlaylistType.playlist:
              context.go('/library/playlists');
            case PlaylistType.station:
              context.go('/library/stations');
            case PlaylistType.album:
              break;
          }
        },
      ),
    );
  }
}

// ── Album filter dropdown ─────────────────────────────────────────────────────
class _AlbumFilterDropdown extends StatelessWidget {
  const _AlbumFilterDropdown({
    required this.sort,
    required this.typeFilter,
    required this.onSortChanged,
    required this.onTypeFilterChanged,
  });

  final _AlbumSort sort;
  final _AlbumTypeFilter typeFilter;
  final ValueChanged<_AlbumSort> onSortChanged;
  final ValueChanged<_AlbumTypeFilter> onTypeFilterChanged;

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
              checked: sort == _AlbumSort.recentlyAdded,
              onTap: () => onSortChanged(_AlbumSort.recentlyAdded),
            ),
            _DropdownItem(
              label: 'First added',
              checked: sort == _AlbumSort.firstAdded,
              onTap: () => onSortChanged(_AlbumSort.firstAdded),
            ),
            _DropdownItem(
              label: 'Album name',
              checked: sort == _AlbumSort.albumName,
              onTap: () => onSortChanged(_AlbumSort.albumName),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFF3A3A3A)),
            // Type filter group
            _DropdownItem(
              label: 'All',
              checked: typeFilter == _AlbumTypeFilter.all,
              onTap: () => onTypeFilterChanged(_AlbumTypeFilter.all),
            ),
            _DropdownItem(
              label: 'Album',
              checked: typeFilter == _AlbumTypeFilter.album,
              onTap: () => onTypeFilterChanged(_AlbumTypeFilter.album),
            ),
            _DropdownItem(
              label: 'Compilation',
              checked: typeFilter == _AlbumTypeFilter.compilation,
              onTap: () =>
                  onTypeFilterChanged(_AlbumTypeFilter.compilation),
            ),
            _DropdownItem(
              label: 'EP',
              checked: typeFilter == _AlbumTypeFilter.ep,
              onTap: () => onTypeFilterChanged(_AlbumTypeFilter.ep),
            ),
            _DropdownItem(
              label: 'Single',
              checked: typeFilter == _AlbumTypeFilter.single,
              onTap: () => onTypeFilterChanged(_AlbumTypeFilter.single),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared dropdown item ──────────────────────────────────────────────────────
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

// ── Album tile ────────────────────────────────────────────────────────────────
class _AlbumTile extends StatelessWidget {
  const _AlbumTile({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            PlaylistCoverImage(playlist: album, size: 60, borderRadius: 0),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: AppTheme.bodyNormal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    album.ownerName.isNotEmpty ? album.ownerName : 'You',
                    style: AppTheme.artistTitle,
                  ),
                  Text(
                    '${album.releaseYear ?? album.createdAt.year} · Album',
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