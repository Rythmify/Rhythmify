import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/home_providers.dart';
import '../../../../core/theme/app_theme.dart';

class MoreOfWhatYouLikeSection extends ConsumerWidget {
  const MoreOfWhatYouLikeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncMixedPlaylists = ref.watch(moreOfWhatYouLikeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("More Of What You Like", style: AppTheme.titleLarge),
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
                  return MoreOfWhatYouLikePlaylistCard(
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

class MoreOfWhatYouLikePlaylistCard extends StatelessWidget {
  final String artists;
  final String imagePath;

  const MoreOfWhatYouLikePlaylistCard({
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
        ],
      ),
    );
  }
}
