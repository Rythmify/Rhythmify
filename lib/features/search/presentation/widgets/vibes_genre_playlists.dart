import 'package:flutter/material.dart';
import '../../domain/entities/vibes_genre_playlist.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as dev;

/// A card displaying a single genre playlist in the Playlists grid.
/// Handles both network and local asset cover images, with a grey fallback on error.
class GenrePlaylistCard extends StatelessWidget {
  const GenrePlaylistCard({super.key, required this.playlist});
  final GenrePlaylist playlist;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        dev.log('playlist id: ${playlist.id}');
        context.push('/home/playlist/${playlist.id}', extra: false);
      },
      child: Column(
        key: Key('genre_playlist_card_${playlist.id}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child:
                playlist.coverImage.isNotEmpty &&
                    playlist.coverImage.startsWith('http')
                ? Image.network(
                    playlist.coverImage,
                    key: Key('genre_playlist_artwork_${playlist.id}'),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 160,
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.music_note,
                          color: Colors.white54,
                          size: 32,
                        ),
                      ),
                    ),
                  )
                : Image.asset(
                    playlist.coverImage.isNotEmpty
                        ? playlist.coverImage
                        : 'assets/images/placeholder.png',
                    key: Key('genre_playlist_artwork_${playlist.id}'),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 160,
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
          const SizedBox(height: 6),
          Text(
            playlist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            playlist.ownerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
