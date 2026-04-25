// lib/features/playlist/presentation/screens/library_stations_screen.dart
// ignore_for_file: avoid_print
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/local/local_saved_store.dart';
import '../providers/saved_content_provider.dart';

enum _StationSort { recentlyAdded, firstAdded, stationName }

class LibraryStationsScreen extends ConsumerStatefulWidget {
  const LibraryStationsScreen({super.key});

  @override
  ConsumerState<LibraryStationsScreen> createState() =>
      _LibraryStationsScreenState();
}

class _LibraryStationsScreenState extends ConsumerState<LibraryStationsScreen> {
  String _searchQuery = '';
  _StationSort _sort = _StationSort.recentlyAdded;

  OverlayEntry? _overlayEntry;
  final _filterIconKey = GlobalKey();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  List<SavedStation> _applySortAndSearch(List<SavedStation> input) {
    var result = List<SavedStation>.from(input);

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (s) => s.stationName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    switch (_sort) {
      case _StationSort.recentlyAdded:
        result.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      case _StationSort.firstAdded:
        result.sort((a, b) => a.savedAt.compareTo(b.savedAt));
      case _StationSort.stationName:
        result.sort(
          (a, b) => a.stationName.toLowerCase().compareTo(
            b.stationName.toLowerCase(),
          ),
        );
    }

    return result;
  }

  bool get _isFiltered => _sort != _StationSort.recentlyAdded;

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
                  child: _StationFilterDropdown(
                    sort: _sort,
                    onSortChanged: (s) {
                      setState(() => _sort = s);
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
    final asyncStations = ref.watch(savedStationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: asyncStations.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryBrand),
          ),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Could not load stations', style: AppTheme.bodyMedium),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      ref.read(savedStationsProvider.notifier).refresh(),
                  child: Text(
                    'Retry',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryBrand,
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (stations) {
            final filtered = _applySortAndSearch(stations);
            return Column(
              children: [
                // ── Search row ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                  child: Row(
                    children: [
                      IconButton(
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
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: AppTheme.bodyNormal,
                            decoration: InputDecoration(
                              hintText:
                                  'Search ${stations.length} station${stations.length == 1 ? '' : 's'}',
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

                // ── Title ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Stations', style: AppTheme.headlineLarge),
                  ),
                ),

                // ── List ───────────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.sensors_off,
                                  color: AppTheme.textSecondary,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  stations.isEmpty
                                      ? 'No saved stations yet\nSave stations from the home screen'
                                      : 'No results for "$_searchQuery"',
                                  style: AppTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          color: AppTheme.primaryBrand,
                          backgroundColor: AppTheme.surface,
                          onRefresh: () => ref
                              .read(savedStationsProvider.notifier)
                              .refresh(),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 140),
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final s = filtered[i];
                              return _StationTile(
                                station: s,
                                onTap: () => context.push(
                                  '/home/station/${s.artistId}',
                                  extra: {
                                    'artistName': s.artistName,
                                    'stationName': s.stationName,
                                    'coverUrl': s.coverUrl,
                                  },
                                ),
                                onUnsave: () => ref
                                    .read(savedStationsProvider.notifier)
                                    .toggle(s),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Station filter dropdown ───────────────────────────────────────────────────
class _StationFilterDropdown extends StatelessWidget {
  const _StationFilterDropdown({
    required this.sort,
    required this.onSortChanged,
  });

  final _StationSort sort;
  final ValueChanged<_StationSort> onSortChanged;

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
              checked: sort == _StationSort.recentlyAdded,
              onTap: () => onSortChanged(_StationSort.recentlyAdded),
            ),
            _DropdownItem(
              label: 'First added',
              checked: sort == _StationSort.firstAdded,
              onTap: () => onSortChanged(_StationSort.firstAdded),
            ),
            _DropdownItem(
              label: 'Station name',
              checked: sort == _StationSort.stationName,
              onTap: () => onSortChanged(_StationSort.stationName),
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

// ── Station tile ──────────────────────────────────────────────────────────────
class _StationTile extends StatelessWidget {
  const _StationTile({
    required this.station,
    required this.onTap,
    required this.onUnsave,
  });

  final SavedStation station;
  final VoidCallback onTap;
  final VoidCallback onUnsave;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 60,
                height: 60,
                child:
                    station.coverUrl != null &&
                        station.coverUrl!.startsWith('http')
                    ? Image.network(
                        station.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.stationName,
                    style: AppTheme.bodyNormal,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(station.artistName, style: AppTheme.artistTitle),
                  Row(
                    children: [
                      const Icon(
                        Icons.sensors,
                        size: 11,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Artist Station · ${station.trackCount} tracks',
                        style: AppTheme.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.sensors_off,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              tooltip: 'Remove station',
              onPressed: onUnsave,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppTheme.surface,
    child: Center(
      child: Text(
        station.stationName.isNotEmpty
            ? station.stationName[0].toUpperCase()
            : 'S',
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}
