import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vibes_genre_providers.dart';
import '../widgets/track_tile.dart';

class GenreTrendingTab extends ConsumerWidget {
  const GenreTrendingTab({super.key, required this.genreId});
  final String genreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(genreTracksProvider(genreId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (tracks) {
        if (tracks.isEmpty) {
          return Center(
            child: Text(
              'No trending tracks',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Trending',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                itemCount: tracks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) => TrackTile(track: tracks[i]),
              ),
            ),
          ],
        );
      },
    );
  }
}
