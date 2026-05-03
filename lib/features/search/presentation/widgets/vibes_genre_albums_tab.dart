import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vibes_genre_providers.dart';
import '../widgets/vibes_genre_albums.dart';

/// The Albums tab on the genre page.
/// Watches [genreAlbumsProvider] for [genreId] and renders a 2-column grid of [GenreAlbumCard].
/// Each tab instance is independently keyed by [genreId] via the autoDispose family provider.
class GenreAlbumsTab extends ConsumerWidget {
  const GenreAlbumsTab({super.key, required this.genreId});
  final String genreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(genreAlbumsProvider(genreId));

    return async.when(
      loading: () => const Center(
        key: Key('genre_albums_loading'),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Center(
        key: const Key('genre_albums_error'),
        child: Text('Error: $e'),
      ),
      data: (albums) {
        if (albums.isEmpty) {
          return Center(
            key: const Key('genre_albums_empty'),
            child: Text(
              'No albums found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }
        return Column(
          key: const Key('genre_albums_content'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Albums',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                key: const Key('genre_albums_grid'),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 200),
                itemCount: albums.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (_, i) => GenreAlbumCard(
                  key: Key('genre_album_card_$i'),
                  album: albums[i],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
