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

enum _AlbumSort { recentlyAdded, firstAdded, albumName }

enum _AlbumTypeFilter { all, album, compilation, ep, single }

extension _AlbumSortLabel on _AlbumSort {}

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
    var result = input.where((p) => p.type == PlaylistType.album).toList();

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

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
      _sort != _AlbumSort.recentlyAdded || _typeFilter != _AlbumTypeFilter.all;

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
      body: SafeArea(
        child: Column(
          children: [
            // ── Search row ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('library_albums_back_button'),
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
                        key: const Key('library_albums_search_field'),
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: AppTheme.bodyNormal,
                        decoration: InputDecoration(
                          hintText:
                              'Search ${filtered.length} album${filtered.length == 1 ? '' : 's'}',
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

            // ── Title ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Albums', style: AppTheme.headlineLarge),
              ),
            ),

            // ── List ───────────────────────────────────────────────
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        key: Key('library_albums_loading_indicator'),
                        color: AppTheme.primaryBrand,
                      ),
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
                      key: const Key('library_albums_list'),
                      padding: const EdgeInsets.only(bottom: 140),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final album = filtered[index];
                        final isOwner = album.ownerId == _currentUserId();
                        return _AlbumTile(
                          key: Key('album_tile_${album.id}'),
                          album: album,
                          onTap: () => context.push(
                            '/home/playlist/${album.id}',
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
    );
  }

  void _showOptions(BuildContext context, PlaylistEntity album, bool isOwner) {
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
              onTap: () => onTypeFilterChanged(_AlbumTypeFilter.compilation),
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
              key: Key('album_tile_more_${album.id}'),
              icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}