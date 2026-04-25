import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import 'track_tile.dart';
import '../../../player/presentation/providers/queue_provider.dart';

/// Search results tab displaying the tracks list from [searchResultsProvider].
/// Renders a loading spinner, error message, empty state, or a scrollable list of [TrackTile].
class TracksTab extends ConsumerWidget {
  const TracksTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);

    return results.when(
      loading: () => const Center(
        key: Key('tracks_loading'),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) =>
          Center(key: const Key('tracks_error'), child: Text('Error: $e')),
      data: (data) {
        if (data.tracks.isEmpty) {
          return Center(
            key: const Key('tracks_empty'),
            child: Text(
              'No tracks found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }
        return ListView.separated(
          key: const Key('tracks_list'),
          padding: const EdgeInsets.all(16),
          itemCount: data.tracks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) => TrackTile(
            key: Key('track_tile_$i'),
            track: data.tracks[i],
            onTap: () {
              ref
                  .read(queueStateProvider.notifier)
                  .playQueue(tracks: data.tracks, initialIndex: i);
            },
          ),
        );
      },
    );
  }
}
