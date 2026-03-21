import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/home_providers.dart';
import '../../../../core/theme/app_theme.dart';

class DiscoverWithStationsSection extends ConsumerWidget {
  const DiscoverWithStationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStations = ref.watch(discoverStationsProvider);

    return Column(
      key: const Key(
        'discover_stations_section',
      ), //key for discover with stations
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Discover with Stations", style: AppTheme.titleLarge),
        ),

        const SizedBox(height: 15),

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
                  return StationCard(
                    key: Key('discover_with_stations_item_${items[index]}'),
                    artists: items[index]['artists'],
                    imagePath: items[index]['image'],
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
  final String artists;
  final String imagePath;

  const StationCard({
    super.key,

    required this.artists,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        key: Key(
          'station_card_container_$artists',
        ), //key for station card container
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image + station badge
          Stack(
            key: Key('station_image_$artists'), //key for image
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5, // very thin border
                  ),
                  image: DecorationImage(
                    image: imagePath.isNotEmpty && imagePath.startsWith('http')
                        ? NetworkImage(imagePath)
                        : const AssetImage('assets/images/track_1.jpg')
                              as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              /// Station badge
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
                      artists,
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

          /// Artist names under the card
          Text(
            key: Key('station_artists_$artists'), //key for artists text
            'Based on$artists',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}