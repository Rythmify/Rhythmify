import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vibes_genre_providers.dart';
import '../widgets/track_tile.dart';
import '../../../player/presentation/providers/queue_provider.dart';

/// The full track list for a genre, used as the child of [GenreSeeAllPage]
/// when the user taps "See all" on the Discover More Tracks section.
/// Watches [genreAllTracksProvider] and renders a scrollable list of [TrackTile].
class GenreAllTracksList extends ConsumerWidget {
  const GenreAllTracksList({super.key, required this.genreId});
  final String genreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(genreAllTracksProvider(genreId));

    return async.when(
      loading: () => const Center(
        key: Key('genre_all_tracks_loading'),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Center(
        key: const Key('genre_all_tracks_error'),
        child: Text('Error: $e'),
      ),
      data: (tracks) {
        if (tracks.isEmpty) {
          return Center(
            key: const Key('genre_all_tracks_empty'),
            child: Text(
              'No tracks found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }
        return ListView.separated(
          key: const Key('genre_all_tracks_list'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: tracks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) => TrackTile(
            key: Key('genre_all_track_$i'),
            track: tracks[i],
            onTap: () {
              ref
                  .read(queueStateProvider.notifier)
                  .playQueue(tracks: tracks, initialIndex: i);
            },
          ),
        );
      },
    );
  }
}
