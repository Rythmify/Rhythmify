import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/home_providers.dart';

/// Widget that renders the "Mixed For You" section.
///
/// This widget:
/// - Observes [mixedPlaylistsProvider]
/// - Displays loading indicator during data fetch
/// - Displays error message if fetching fails
/// - Displays a horizontal list of mixed playlist cards when data is available
class MixedPlaylistsSection extends ConsumerWidget {
  const MixedPlaylistsSection({super.key});

  /// Builds the Mixed For You section UI.
  ///
  /// Parameters:
  /// - context: Build context used for rendering UI
  /// - ref: Riverpod reference used to watch providers
  ///
  /// Returns:
  /// - A widget containing title, loading/error state, and playlist cards
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMixedPlaylists = ref.watch(mixedPlaylistsProvider);

    return Column(
      key: const Key('mixed_for_you_section'), //KEY FOR mixed for you section
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Mixed For You", style: AppTheme.titleLarge),
        ),

        const SizedBox(height: 15),

        asyncMixedPlaylists.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              Text("Error: $e", key: const Key('mixed_for_you_error_text')),
          data: (items) {
            final list = items as List;
            if (list.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 160,
              child: ListView.separated(
                key: const Key('mixed_list_view'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = list[index] as Map<String, dynamic>;
                  return MixedPlaylistCard(
                    key: Key('mixed_for_you_item_${item['id'] ?? index}'),
                    artists: item['artists'] ?? '',
                    imagePath: item['image'] ?? '',
                    mixLabel: item['mixLabel'] ?? '',
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

/// Card widget representing a mixed playlist recommendation.
///
/// Each card displays:
/// - Playlist cover image
/// - Mix label badge (e.g., genre or category)
/// - Artist names associated with the playlist
///
/// This widget is purely presentational and does not manage state.
class MixedPlaylistCard extends StatelessWidget {
  /// Label describing the type of mix (e.g., genre or theme).
  final String mixLabel;

  /// Artist names included in the playlist.
  final String artists;

  /// Image asset path representing playlist artwork.
  final String imagePath;

  const MixedPlaylistCard({
    super.key,
    required this.mixLabel,
    required this.artists,
    required this.imagePath,
  });

  /// Builds the UI for a single mixed playlist card.
  ///
  /// Parameters:
  /// - context: Build context for rendering UI
  ///
  /// Returns:
  /// - A styled playlist card widget containing image, badge, and text
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: Key('mixed_card_container_$mixLabel'), //key for card root
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image + Mix badge
          Stack(
            children: [
              Container(
                key: Key('mixed_image_$mixLabel'), //key for image
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5, // very thin border
                  ),
                  image: imagePath.isNotEmpty
                      ? DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imagePath.isEmpty
                    ? const Center(child: Icon(Icons.music_note))
                    : null,
              ),

              /// Mix label badge
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.only(top: 3, left: 10, right: 80),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(180),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    key: Key('mixed_label_$mixLabel'), //key for  mixlabel
                    mixLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Artist names under the card
          Text(
            key: Key('mixed_artists_$mixLabel'), //key for artists text
            artists,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
