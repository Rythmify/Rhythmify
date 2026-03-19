import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/home_providers.dart';
import '../../../../core/theme/app_theme.dart';

class DiscoverWithStationsSection extends ConsumerWidget {
  const DiscoverWithStationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncStations = ref.watch(discoverStationsProvider);

    return Container(
      key: const Key(
        'discover_stations_section',
      ), //key for discover with stations
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
              final stations = items as List<dynamic>;
              return SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: stations.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 15),
                  itemBuilder: (context, index) {
                    final item = stations[index] as Map<String, dynamic>;
                    return StationCard(
                      key: Key(
                        'discover_with_stations_item_${item['id'] ?? index}',
                      ),
                      artists: item['artists'] ?? '',
                      imagePath: item['image'] ?? '',
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
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
    return Column(
      key: Key(
        'station_card_container_$artists',
      ), //key for station card container
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Station Circle
        Container(
          key: Key('station_image_$artists'), //key for image
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF6C7C71), width: 2),
            image: imagePath.isNotEmpty
                ? (imagePath.startsWith('http')
                      ? DecorationImage(
                          image: NetworkImage(imagePath),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        ))
                : null,
          ),
          child: imagePath.isEmpty
              ? const Center(child: Icon(Icons.radio))
              : null,
        ),

        const SizedBox(height: 8),

        /// Artist names
        SizedBox(
          width: 110,
          child: Text(
            key: Key('station_artists_$artists'), //key for artists text
            artists,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
