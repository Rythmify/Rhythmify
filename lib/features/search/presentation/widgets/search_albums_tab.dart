import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';

class AlbumsTab extends ConsumerWidget {
  const AlbumsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider);

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
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
          itemCount: albums.length,
          itemBuilder: (context, index) =>
              _AlbumTile(key: Key('album_tile_$index'), album: albums[index]),
        );
      },
    );
  }
}

class _AlbumTile extends StatelessWidget {
  final Map<String, String> album;
  const _AlbumTile({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            album['artworkUrl']!,
            key: Key('album_artwork_${album['id']}'),
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Container(width: 50, height: 50, color: Colors.grey[800]),
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
    );
  }
}
