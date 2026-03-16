import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/home_providers.dart';
import '../../../../core/theme/app_theme.dart';

class DiscoverWithStationsSection extends ConsumerWidget {
  const DiscoverWithStationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMixedPlaylists = ref.watch(discoverStationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Discover with Stations", style: AppTheme.titleLarge),
        ),

        const SizedBox(height: 15),

        asyncMixedPlaylists.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text("Error: $e"),
          data: (items) {
            return SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return StationPlaylistCard(
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

class StationPlaylistCard extends StatelessWidget {
  final String artists;
  final String imagePath;

  const StationPlaylistCard({
    super.key,

    required this.artists,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image + station badge
          Stack(
            children: [
              Container(
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5, // very thin border
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imagePath),
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
            'Based on$artists',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
