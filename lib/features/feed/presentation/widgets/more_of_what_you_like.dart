import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/home_providers.dart';
import '../../../../core/theme/app_theme.dart';

class MoreOfWhatYouLikeSection extends ConsumerWidget {
  const MoreOfWhatYouLikeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMore = ref.watch(moreOfWhatYouLikeProvider);

    return Column(
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

class PlaylistSquareCard extends StatelessWidget {
  final String artists;
  final String imagePath;

  const PlaylistSquareCard({
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
          /// Square Artwork
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              border: Border.all(
                color: const Color(0xFF6C7C71),
                width: 0.5,
              ),
              image: imagePath.isNotEmpty 
                ? (imagePath.startsWith('http') 
                    ? DecorationImage(image: NetworkImage(imagePath), fit: BoxFit.cover)
                    : DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover))
                : null,
            ),
            child: imagePath.isEmpty ? const Center(child: Icon(Icons.playlist_play)) : null,
          ),

          const SizedBox(height: 8),

          /// Artist names
          Text(
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
