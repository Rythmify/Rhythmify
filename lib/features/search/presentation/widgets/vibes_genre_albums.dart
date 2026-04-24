import 'package:flutter/material.dart';
import '../../domain/entities/vibes_genre_album.dart';
import 'package:go_router/go_router.dart';

/// A card displaying a single genre album in the Albums grid.
/// Handles both network and local asset cover images, with a grey fallback on error.
class GenreAlbumCard extends StatelessWidget {
  const GenreAlbumCard({super.key, required this.album});
  final GenreAlbum album;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/playlist/${album.id}', extra: false);
      },
      child: Column(
        key: Key('genre_album_card_${album.id}'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            // Uses [Image.network] for http URLs, [Image.asset] for local paths.
            child:
                album.coverImage.isNotEmpty &&
                    album.coverImage.startsWith('http')
                ? Image.network(
                    album.coverImage,
                    key: Key('genre_album_artwork_${album.id}'),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(height: 160, color: Colors.grey[800]),
                  )
                : Image.asset(
                    album.coverImage.isNotEmpty
                        ? album.coverImage
                        : 'assets/images/placeholder.png',
                    key: Key('genre_album_artwork_${album.id}'),
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(height: 160, color: Colors.grey[800]),
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            album.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            album.ownerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
