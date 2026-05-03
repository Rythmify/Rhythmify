import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import 'package:go_router/go_router.dart';

/// Search results tab displaying the albums list from [searchResultsProvider].
/// Renders a loading spinner, error message, empty state, or a scrollable list of [_AlbumTile].
class AlbumsTab extends ConsumerWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchAlbumsProvider);

    return resultsAsync.when(
      loading: () => const Center(
        key: Key('albums_loading'),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) =>
          Center(key: const Key('albums_error'), child: Text('Error: $e')),
      data: (results) {
        final albums = results.albums;
        if (albums.isEmpty) {
          return Center(
            key: const Key('albums_empty'),
            child: Text(
              'No albums found',
              style: TextStyle(color: Colors.grey[500]),
            ),
          );
        }
        return ListView.builder(
          key: const Key('albums_list'),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 200),
          itemCount: albums.length,
          itemBuilder: (context, index) =>
              _AlbumTile(key: Key('album_tile_$index'), album: albums[index]),
        );
      },
    );
  }
}

/// A single album row showing artwork, title, artist, year, and type.
/// Accepts a raw [Map<String, String>] until a teammate-owned Album entity is available.
class _AlbumTile extends StatelessWidget {
  final Map<String, String> album;
  const _AlbumTile({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/home/playlist/${album['id']}', extra: false);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              album['artworkUrl'] ?? '',

              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 50,
                height: 50,
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white54,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            album['title']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                album['artist']!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              Text(
                '${album['year']} · ${album['type']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
          trailing: const Icon(Icons.more_vert),
          isThreeLine: true,
        ),
      ),
    );
  }
}
