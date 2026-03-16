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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text("Mixed For You", style: AppTheme.titleLarge),
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
                  return MixedPlaylistCard(
                    artists: items[index]['artists'],
                    imagePath: items[index]['image'],
                    mixLabel: items[index]['mixLabel'],
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
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image + Mix badge
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
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
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
