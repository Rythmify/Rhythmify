import 'package:flutter/material.dart';
import '../../domain/entities/vibes_genre_artists.dart';

/// A compact vertical artist card used in the Profiles horizontal scroll on the genre page.
/// Shows a circular avatar, display name, and a Follow button.
/// Handles network, local asset, and missing profile pictures.
class GenreProfileCard extends StatelessWidget {
  const GenreProfileCard({super.key, required this.artist});
  final GenreArtist artist;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          CircleAvatar(
            key: Key('genre_profile_avatar_${artist.id}'),
            radius: 40,
            backgroundColor: Colors.grey[800],
            // Uses NetworkImage for http URLs, AssetImage for local paths, falls back to icon.
            backgroundImage: artist.profilePicture.isNotEmpty
                ? (artist.profilePicture.startsWith('http')
                      ? NetworkImage(artist.profilePicture) as ImageProvider
                      : AssetImage(artist.profilePicture))
                : null,
            child: artist.profilePicture.isEmpty
                ? const Icon(Icons.person, size: 36, color: Colors.white)
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            artist.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 6),
          OutlinedButton(
            key: Key('genre_profile_follow_${artist.id}'),
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: const Color(0xffffffff),
              foregroundColor: const Color(0xff000000),
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(fontSize: 13),
            ),
            child: const Text('Follow'),
          ),
        ],
      ),
    );
  }
}
