import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/home_providers.dart';
import '../../../../core/theme/app_theme.dart';

class MixedPlaylistsSection extends ConsumerWidget {
  const MixedPlaylistsSection({super.key});

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
          loading: () => const Center(
            key: Key('mixed_loading'),
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => Text("Error: $e"),
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
                    key: Key('mixed_card_$index'), //key foreach card
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

class MixedPlaylistCard extends StatelessWidget {
  final String mixLabel;
  final String artists;
  final String imagePath;

  const MixedPlaylistCard({
    super.key,
    required this.mixLabel,
    required this.artists,
    required this.imagePath,
  });

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
