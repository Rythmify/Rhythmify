import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_providers.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'shimmers/playlist_card_shimmer.dart';

class MoreOfWhatYouLikeSection extends ConsumerWidget {
  const MoreOfWhatYouLikeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMore = ref.watch(moreOfWhatYouLikeProvider);

    return Column(
      key: const Key('more_of_what_you_like_section'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 16),
          child: Text("More of what you like", style: AppTheme.homeTitle),
        ),
        asyncMore.when(
          loading: () => SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => const PlaylistCardShimmer(),
            ),
          ),
          error: (e, _) => Text(
            "Error: $e",
            key: const Key('more_of_what_you_like_error_text'),
          ),
          data: (tracks) {
            if (tracks.isEmpty) return const SizedBox.shrink();
            return SizedBox(
              height: 180,
              child: ListView.separated(
                key: const Key('more_list_view'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tracks.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return PlaylistSquareCard(
                    key: Key('item_$index'),
                    id: track.id,
                    artistName: track.artist,
                    imagePath: track.coverImage ?? '',
                    trackTitle: track.title,
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
  final String artistName;
  final String imagePath;
  final String id;
  final String trackTitle;

  const PlaylistSquareCard({
    super.key,
    required this.id,
    required this.artistName,
    required this.imagePath,
    required this.trackTitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/home/related-tracks/$id',
        extra: {
          'basedOnName': artistName,
          'title': trackTitle,
          'coverUrl': imagePath,
        },
      ),

      child: SizedBox(
        key: Key('more_card_container_$artistName'),
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              key: Key('more_image_$artistName'),
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                border: Border.all(color: const Color(0xFF6C7C71), width: 0.5),
                image: imagePath.isNotEmpty
                    ? DecorationImage(
                        image: imagePath.startsWith('http')
                            ? NetworkImage(imagePath) as ImageProvider
                            : AssetImage(imagePath),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imagePath.isEmpty
                  ? const Center(child: Icon(Icons.playlist_play))
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              key: Key('more_artists_$artistName'),
              artistName,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
