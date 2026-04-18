// lib/features/playlist/presentation/screens/library_stations_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/playlist_entity.dart';
import '../providers/playlist_provider.dart';
import '../widgets/playlist_options_sheet.dart';
import '../widgets/playlist_shared_widgets.dart';

/// Library → Stations.
/// Filters playlistListProvider to only show type == station.
class LibraryStationsScreen extends ConsumerStatefulWidget {
  const LibraryStationsScreen({super.key});

  @override
  ConsumerState<LibraryStationsScreen> createState() =>
      _LibraryStationsScreenState();
}

class _LibraryStationsScreenState
    extends ConsumerState<LibraryStationsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playlistListProvider);
    final allStations = state.playlists
        .where((p) => p.type == PlaylistType.station)
        .toList();
    final filtered = allStations
        .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          key: const Key('library_stations_back_button'),
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Stations',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
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
                      key: const Key('library_stations_search_field'),
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText:
                            'Search ${allStations.length} station${allStations.length == 1 ? '' : 's'}',
                        hintStyle:
                            TextStyle(color: Colors.grey[600], fontSize: 14),
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
                          ? 'No stations yet.\n\nOpen a playlist → ··· → Edit\n→ Convert to Station.'
                          : 'No results for "$_searchQuery"',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final station = filtered[index];
                      return _StationTile(
                        key: Key('library_station_tile_${station.id}'),
                        station: station,
                        onTap: () => context.push(
                          '/library/stations/${station.id}',
                          extra: true,
                        ),
                        onMoreTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => PlaylistOptionsSheet(
                            playlistId: station.id,
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
      case PlaylistType.album:
        context.go('/library/albums');
      case PlaylistType.station:
        break;
    }
  }
}

class _StationTile extends StatelessWidget {
  const _StationTile({
    super.key,
    required this.station,
    required this.onTap,
    required this.onMoreTap,
  });

  final PlaylistEntity station;
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
            PlaylistCoverImage(playlist: station, size: 65, borderRadius: 4),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text(
                    station.seedArtistName != null
                        ? 'Based on ${station.seedArtistName}'
                        : station.ownerName,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    station.detailSubtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              key: Key('station_tile_more_${station.id}'),
              icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
              onPressed: onMoreTap,
            ),
          ],
        ),
      ),
    );
  }
}