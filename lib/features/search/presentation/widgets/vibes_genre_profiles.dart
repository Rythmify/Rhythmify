import 'package:flutter/material.dart';
import '../../domain/entities/vibes_genre_artists.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/follow_button.dart';

/// A compact vertical artist card used in the Profiles horizontal scroll on the genre page.
/// Shows a circular avatar, display name, and a Follow button.
/// Handles network, local asset, and missing profile pictures.
class GenreProfileCard extends StatelessWidget {
  const GenreProfileCard({super.key, required this.artist});
  final GenreArtist artist;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/profile/${artist.id}'),
      child: SizedBox(
        width: 100, // Slightly increased to fit "Following" text if needed
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
            FollowButton(targetUserId: artist.id, compact: true),
          ],
        ),
      ),
    );
  }
}
