import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_providers.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget that renders the "More of what you like" section.
///
/// This widget:
/// - Watches [moreOfWhatYouLikeProvider]
/// - Displays loading indicator while fetching data
/// - Displays error message if fetching fails
/// - Displays a horizontal list of playlist cards when data is available
class MoreOfWhatYouLikeSection extends ConsumerWidget {
  const MoreOfWhatYouLikeSection({super.key});

  /// Builds the More of what you like section UI.
  ///
  /// Parameters:
  /// - context: Build context for rendering widgets
  /// - ref: Riverpod reference used to watch providers
  ///
  /// Returns:
  /// - A widget containing title, loading/error state, and playlist cards
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMore = ref.watch(moreOfWhatYouLikeProvider);

    return Column(
      key: const Key('more_of_what_you_like_section'), //key for whole section
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("More of what you like", style: AppTheme.titleLarge),
        ),

        const SizedBox(height: 15),

        asyncMore.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(
            "Error: $e",
            key: const Key('more_of_what_you_like_error_text'),
          ),
          data: (items) {
            final list = items as List;
            if (list.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 180,
              child: ListView.separated(
                key: const Key('more_list_view'), //key for horizontal list
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = list[index] as Map<String, dynamic>;
                  return PlaylistSquareCard(
                    key: Key('item_$index'),
                    artists: item['artists'] ?? '',
                    imagePath: item['image'] ?? '',
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

/// Card widget representing a square playlist recommendation.
///
/// Each card displays:
/// - Playlist artwork (network or asset image)
/// - Artist names associated with the playlist
///
/// This widget is purely presentational and does not manage state.
class PlaylistSquareCard extends StatelessWidget {
  /// Artist name(s) associated with this playlist.
  final String artists;

  /// Image URL or asset path for playlist artwork.
  final String imagePath;

  const PlaylistSquareCard({
    super.key,
    required this.artists,
    required this.imagePath,
  });

  /// Builds the UI for a square playlist card.
  ///
  /// Parameters:
  /// - context: Build context used for rendering UI
  ///
  /// Returns:
  /// - A styled playlist card widget containing image and text
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: Key('more_card_container_$artists'), //key forcard root
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Square Artwork
          Container(
            key: Key('more_image_$artists'), //key for image
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              border: Border.all(color: const Color(0xFF6C7C71), width: 0.5),
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
                ? const Center(child: Icon(Icons.playlist_play))
                : null,
          ),

          const SizedBox(height: 8),

          /// Artist names
          Text(
            key: Key('more_artists_$artists'), //key for artists text
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
