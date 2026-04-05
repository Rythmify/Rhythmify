import 'package:flutter/material.dart';

class GenrePlaylistCard extends StatelessWidget {
  const GenrePlaylistCard({super.key, required this.playlist});
  final Map<String, String> playlist;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key('genre_playlist_card_${playlist['id']}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Image.asset(
            'assets/images/placeholder.png',
            key: Key('genre_playlist_artwork_${playlist['id']}'),
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Container(height: 160, color: Colors.grey[800]),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          playlist['title'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          playlist['creatorName'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }
}
