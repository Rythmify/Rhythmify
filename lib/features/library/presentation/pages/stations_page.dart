import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/library_providers.dart';
import '../../domain/entities/library_entities.dart';

/// Displays artist-based radio stations seeded from followed artists.
class StationsPage extends ConsumerWidget {
  const StationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stationsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Stations'), centerTitle: false),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBrand)),
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
        data: (stations) {
          if (stations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.radio, color: AppTheme.textSecondary, size: 56),
                  const SizedBox(height: 16),
                  Text('No stations yet', style: AppTheme.titleMedium.copyWith(color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Follow artists to get personalized stations.', style: AppTheme.bodyMedium, textAlign: TextAlign.center),
                ],
              ),
            );
          }

          return GridView.builder(
            key: const Key('stations_grid_view'),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: stations.length,
            itemBuilder: (context, index) => _StationCard(station: stations[index]),
          );
        },
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  final LibraryStation station;

  const _StationCard({required this.station});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('station_item_${station.id}_gesture_detector'),
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: station.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: station.coverUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (c, u, e) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    key: Key('station_item_${station.id}_name_text'),
                    style: AppTheme.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${station.trackCount} tracks',
                    key: Key('station_item_${station.id}_track_count_text'),
                    style: AppTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppTheme.lighterSurface,
    child: const Center(child: Icon(Icons.radio, color: AppTheme.textSecondary, size: 40)),
  );
}
