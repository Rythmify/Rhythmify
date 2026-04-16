import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';

import '../providers/home_providers.dart';

class DiscoverWithStationsSection extends ConsumerWidget {
  const DiscoverWithStationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStations = ref.watch(discoverStationsProvider);

    return Column(
      key: const Key('discover_stations_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 16),
          child: Text("Discover with Stations", style: AppTheme.homeTitle),
        ),
        asyncStations.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            "Error: $e",
            key: const Key('discover_with_stations_error_text'),
          ),
          data: (items) {
            return SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final station = items[index];
                  return StationCard(
                    key: Key('discover_with_stations_item_${station.id}'),
                    id: station.id,
                    artistName: station.artistName,
                    imagePath: station.coverImage,
                    stationName: station.name,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class StationCard extends StatelessWidget {
  final String artistName;
  final String imagePath;
  final String stationName;
  final String id;

  const StationCard({
    super.key,
    required this.id,
    required this.artistName,
    required this.imagePath,
    required this.stationName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        key: Key('station_card_container_$artistName'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            key: Key('station_image_$artistName'),
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  border: Border.all(color: Colors.grey, width: 0.5),
                  color: Colors.grey[900], // dark background when no image
                  image: imagePath.isNotEmpty && imagePath.startsWith('http')
                      ? DecorationImage(
                          image: NetworkImage(imagePath),
                          fit: BoxFit.cover,
                        )
                      : null, // no image — just shows the dark background
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "STATIONS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Text(
                      artistName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            key: Key('station_artists_$artistName'),
            stationName,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
