import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vibes_genre_providers.dart';
import '../widgets/vibes_genre_playlists.dart';

/// The Playlists tab on the genre page.
/// Watches [genrePlaylistsProvider] for [genreId] and renders a 2-column grid of [GenrePlaylistCard].
/// Each tab instance is independently keyed by [genreId] via the autoDispose family provider.
class GenrePlaylistsTab extends ConsumerWidget {
  const GenrePlaylistsTab({super.key, required this.genreId});
  final String genreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(genrePlaylistsProvider(genreId));

    return async.when(
      loading: () => const Center(
        key: Key('genre_playlists_loading'),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Center(
        key: const Key('genre_playlists_error'),
        child: Text('Error: $e'),
      ),
      data: (playlists) {
        if (playlists.isEmpty) {
          return Center(
            key: const Key('genre_playlists_empty'),
            child: Text(
              'No playlists found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }
        return Column(
          key: const Key('genre_playlists_content'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Playlists',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                key: const Key('genre_playlists_grid'),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 200),
                itemCount: playlists.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (_, i) => GenrePlaylistCard(
                  key: Key('genre_playlist_card_$i'),
                  playlist: playlists[i],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
