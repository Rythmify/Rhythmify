import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_providers.dart';
import '../../../../core/utils/formatters.dart';

/// Search results tab displaying the playlists list from [searchResultsProvider].
/// Renders a loading spinner, error message, empty state, or a scrollable list of [_PlaylistTile].
class PlaylistsTab extends ConsumerWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider);

    return resultsAsync.when(
      loading: () => const Center(
        key: Key('playlists_loading'),
        child: CircularProgressIndicator(),
      ),
      error: (e, _) =>
          Center(key: const Key('playlists_error'), child: Text('Error: $e')),
      data: (results) {
        final playlists = results.playlists;
        if (playlists.isEmpty) {
          return Center(
            key: const Key('playlists_empty'),
            child: Text(
              'No playlists found',
              style: TextStyle(color: Colors.grey[500]),
            ),
          );
        }
        return ListView.builder(
          key: const Key('playlists_list'),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
          itemCount: playlists.length,
          itemBuilder: (context, index) => _PlaylistTile(
            key: Key('playlist_tile_$index'),
            playlist: playlists[index],
          ),
        );
      },
    );
  }
}

/// A single playlist row showing artwork, title, track count, and formatted duration.
/// Accepts a raw [Map<String, String>] until a teammate-owned Playlist entity is available.
class _PlaylistTile extends StatelessWidget {
  final Map<String, String> playlist;
  const _PlaylistTile({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final artworkUrl = playlist['artworkUrl'] ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: artworkUrl.isNotEmpty && artworkUrl.startsWith('http')
              ? Image.network(
                  artworkUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Container(width: 50, height: 50, color: Colors.grey[800]),
                )
              : Container(width: 50, height: 50, color: Colors.grey[800]),
        ),
        title: Text(
          playlist['title']!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Duration is formatted from raw seconds via [Formatters.formatPlaylistDuration].
        subtitle: Text(
          'Playlist · ${playlist['trackCount']} tracks · ${Formatters.formatPlaylistDuration(int.parse(playlist['totalSeconds'] ?? '0'))}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        trailing: const Icon(Icons.more_horiz),
      ),
    );
  }
}
