import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/home_providers.dart';

/// Widget that displays the "Discover with Stations" section.
///
/// This widget:
/// - Watches discoverStationsProvider for station data
/// - Displays loading indicator while fetching data
/// - Displays error message if fetching fails
/// - Displays a horizontal list of StationCard widgets when data is available
class DiscoverWithStationsSection extends ConsumerWidget {
  const DiscoverWithStationsSection({super.key});

  /// Builds the UI for the Discover with Stations section.
  ///
  /// Parameters:
  /// - context: Build context for rendering widgets
  /// - ref: Riverpod reference used to watch providers
  ///
  /// Returns:
  /// - A widget containing section title, loading/error state, and station list UI
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

/// A UI card that represents a single music discovery station.
///
/// Each card shows:
/// - Station image (network or fallback asset)
/// - "STATIONS" overlay label
/// - Artists used as the recommendation seed
///
/// This widget is purely presentational and does not manage state.
class StationCard extends StatelessWidget {
  /// Artist name(s) used to generate the station.
  final String artists;

  /// Image URL or local asset path for station artwork.
  final String imagePath;

  const StationCard({
    super.key,

    required this.artists,
    required this.imagePath,
  });

  /// Builds the UI for a single station card.
  ///
  /// Parameters:
  /// - context: Build context for rendering UI
  ///
  /// Returns:
  /// - A styled station card widget with image and text overlay
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
