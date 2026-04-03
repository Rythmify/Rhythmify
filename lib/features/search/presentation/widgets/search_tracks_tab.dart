import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import 'track_tile.dart';

class TracksTab extends ConsumerWidget {
  const TracksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (data) {
        if (data.tracks.isEmpty) {
          return Center(
            child: Text(
              'No tracks found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.tracks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) => TrackTile(track: data.tracks[i]),
        );
      },
    );
  }
}
