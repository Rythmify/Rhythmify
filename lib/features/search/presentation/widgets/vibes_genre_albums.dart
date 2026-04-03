import 'package:flutter/material.dart';

class GenreAlbumCard extends StatelessWidget {
  const GenreAlbumCard({super.key, required this.album});
  final Map<String, String> album;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Image.asset(
            album['coverImage'] ?? 'assets/images/placeholder.png',
            width: double.infinity,
            height: 160,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                Container(height: 160, color: Colors.grey[800]),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          album['title'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          album['artistName'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }
}
