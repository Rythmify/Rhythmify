import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';

///
/// Empty state: centered text + "Begin search" [OutlinedButton] with [StadiumBorder].
/// Loaded state: list of station tiles.
class StationsPage extends ConsumerWidget {
  const StationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Stations'), centerTitle: false),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBrand),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(e.toString(), style: AppTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const Key('stations_retry_button'),
                onPressed: () => ref.invalidate(stationsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (stations) =>
            stations.isEmpty ? _buildEmpty(context) : _buildList(stations),
      ),
    );
  }

  // ── Empty state matching SoundCloud ──────────────────────────────────────────
  Widget _buildEmpty(BuildContext context) {
    return Center(
      key: const Key('stations_empty_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No stations yet',
              key: const Key('stations_empty_headline_text'),
              style: AppTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Stations you have liked will show up here. To start a station, just search for a track or artist, then tap the menu and select "Start station".',
              key: const Key('stations_empty_body_text'),
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              key: const Key('stations_begin_search_button'),
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textPrimary,
                side: const BorderSide(color: AppTheme.textSecondary),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Begin search'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loaded list ───────────────────────────────────────────────────────────────
  Widget _buildList(List<LibraryStation> stations) {
    return ListView.builder(
      key: const Key('stations_list_view'),
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: stations.length,
      itemBuilder: (context, index) => _StationTile(station: stations[index]),
    );
  }
}

class _StationTile extends StatelessWidget {
  final LibraryStation station;
  const _StationTile({required this.station});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key('station_item_${station.id}_list_tile'),
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: station.coverUrl != null
            ? CachedNetworkImage(
                imageUrl: station.coverUrl!,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorWidget: (c, u, e) => _placeholder(),
              )
            : _placeholder(),
      ),
      title: Text(
        station.name,
        key: Key('station_item_${station.id}_name_text'),
        style: AppTheme.labelLarge,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${station.trackCount} · Track station',
        key: Key('station_item_${station.id}_meta_text'),
        style: AppTheme.labelSmall,
      ),
      trailing: const Icon(
        Icons.more_vert,
        color: AppTheme.textSecondary,
        size: 20,
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 52,
    height: 52,
    color: AppTheme.lighterSurface,
    child: const Icon(Icons.radio, color: AppTheme.textSecondary),
  );
}
