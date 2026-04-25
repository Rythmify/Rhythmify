// lib/features/playlist/presentation/screens/library_stations_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/local/local_saved_store.dart';
import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import '../providers/saved_content_provider.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_shared_widgets.dart';

class LibraryStationsScreen extends ConsumerStatefulWidget {
  const LibraryStationsScreen({super.key});

  @override
  ConsumerState<LibraryStationsScreen> createState() =>
      _LibraryStationsScreenState();
}

class _LibraryStationsScreenState extends ConsumerState<LibraryStationsScreen> {
  String _searchQuery = '';
  bool _showSaved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playlistListProvider.notifier).loadPlaylists();
      // Trigger the AsyncNotifier to load from disk
      ref.read(savedStationsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(playlistListProvider);

    final savedStations = ref
        .watch(savedStationsProvider)
        .maybeWhen(data: (list) => list, orElse: () => <SavedStation>[]);

    final myStations = listState.playlists
        .where((p) => p.type == PlaylistType.station)
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    final filteredSaved = savedStations
        .where(
          (s) =>
              s.stationName.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          key: const Key('library_stations_back_button'),
          icon: const Icon(
            Icons.chevron_left,
            color: AppTheme.textPrimary,
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text('Stations', style: AppTheme.titleMedium),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                key: const Key('library_stations_search_field'),
                onChanged: (v) => setState(() => _searchQuery = v),
                style: AppTheme.bodyNormal,
                decoration: InputDecoration(
                  hintText: _showSaved
                      ? 'Search ${filteredSaved.length} saved stations'
                      : 'Search ${myStations.length} stations',
                  hintStyle: AppTheme.bodyMedium,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          // ── My Stations / Saved toggle ────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                _FilterChip(
                  label: 'My Stations',
                  selected: !_showSaved,
                  onTap: () => setState(() => _showSaved = false),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Saved',
                  selected: _showSaved,
                  onTap: () => setState(() => _showSaved = true),
                ),
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: _showSaved
                ? _SavedStationsList(
                    stations: filteredSaved,
                    searchQuery: _searchQuery,
                  )
                : _MyStationsList(
                    stations: myStations,
                    isLoading: listState.isLoading,
                    searchQuery: _searchQuery,
                  ),
          ),
        ],
      ),
    );
  }
}

// ── My Stations ───────────────────────────────────────────────────────────────
class _MyStationsList extends ConsumerWidget {
  const _MyStationsList({
    required this.stations,
    required this.isLoading,
    required this.searchQuery,
  });
  final List<PlaylistEntity> stations;
  final bool isLoading;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrand),
      );
    }
    if (stations.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isEmpty
              ? 'No stations yet.\n\nOpen a playlist → ··· → Edit\n→ Convert to Station.'
              : 'No results for "$searchQuery"',
          textAlign: TextAlign.center,
          style: AppTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 140),
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        return _StationTile(
          key: Key('my_station_tile_${station.id}'),
          title: station.name,
          subtitle: station.seedArtistName != null
              ? 'Based on ${station.seedArtistName}'
              : station.ownerName,
          detail: station.detailSubtitle,
          coverUrl: station.coverUrl,
          isMyStation: true,
          onTap: () =>
              context.push('/home/playlist/${station.id}', extra: true),
          onMoreTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => PlaylistOptionsSheet(
              playlistId: station.id,
              isOwner: true,
              onConverted: (t) {
                switch (t) {
                  case PlaylistType.playlist:
                    context.go('/library/playlists');
                  case PlaylistType.album:
                    context.go('/library/albums');
                  case PlaylistType.station:
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }
}

// ── Saved Stations ────────────────────────────────────────────────────────────
class _SavedStationsList extends ConsumerWidget {
  const _SavedStationsList({required this.stations, required this.searchQuery});
  final List<SavedStation> stations;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (stations.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isEmpty
              ? 'No saved stations yet.\n\nLike a station from Home\nor Search to save it here.'
              : 'No results for "$searchQuery"',
          textAlign: TextAlign.center,
          style: AppTheme.bodyMedium,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 140),
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final s = stations[index];
        return _StationTile(
          key: Key('saved_station_tile_${s.artistId}'),
          title: s.stationName,
          subtitle: 'Based on ${s.artistName}',
          detail: '${s.trackCount} tracks',
          coverUrl: s.coverUrl,
          isMyStation: false,
          onTap: () => context.push(
            '/station/${s.artistId}',
            extra: {
              'artistName': s.artistName,
              'stationName': s.stationName,
              'coverUrl': s.coverUrl,
            },
          ),
          onMoreTap: () => _showOptions(context, ref, s),
        );
      },
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, SavedStation s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 90,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  _CoverThumb(url: s.coverUrl, label: s.stationName),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.stationName, style: AppTheme.bodyNormal),
                        Text(
                          'Based on ${s.artistName}',
                          style: AppTheme.artistTitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.lighterSurface, height: 1),
            OptionSheetTile(
              icon: Icons.sensors_off,
              label: 'Remove from Saved',
              onTap: () {
                ref.read(savedStationsProvider.notifier).remove(s.artistId);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Station tile ──────────────────────────────────────────────────────────────
class _StationTile extends StatelessWidget {
  const _StationTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.coverUrl,
    required this.isMyStation,
    required this.onTap,
    required this.onMoreTap,
  });

  final String title;
  final String subtitle;
  final String detail;
  final String? coverUrl;
  final bool isMyStation;
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 65,
                    height: 65,
                    child:
                        coverUrl != null &&
                            coverUrl!.isNotEmpty &&
                            coverUrl!.startsWith('http')
                        ? Image.network(
                            coverUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _placeholder(title),
                          )
                        : _placeholder(title),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBrand,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sensors,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyNormal,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.artistTitle,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (isMyStation)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.lighterSurface),
                          ),
                          child: Text(
                            'My Station',
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.primaryBrand,
                            ),
                          ),
                        ),
                      Flexible(
                        child: Text(
                          detail,
                          style: AppTheme.labelSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(String label) => Container(
    color: AppTheme.surface,
    child: Center(
      child: Icon(
        Icons.sensors,
        color: AppTheme.primaryBrand.withValues(alpha: 0.6),
        size: 28,
      ),
    ),
  );
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBrand : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryBrand : AppTheme.lighterSurface,
          ),
        ),
        child: Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CoverThumb extends StatelessWidget {
  const _CoverThumb({required this.url, required this.label});
  final String? url;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 56,
        height: 56,
        child: url != null && url!.isNotEmpty && url!.startsWith('http')
            ? Image.network(url!, fit: BoxFit.cover)
            : Container(
                color: AppTheme.surface,
                child: const Center(
                  child: Icon(
                    Icons.sensors,
                    color: AppTheme.primaryBrand,
                    size: 24,
                  ),
                ),
              ),
      ),
    );
  }
}
