/// Represents an artist entry displayed on a genre/vibes page.
class GenreArtist {
  final String id;
  final String displayName;
  final String username;
  final String profilePicture;
  final bool isVerified;
  final int followerCount;

  /// Number of tracks this artist has within the specific genre.
  final int trackCountInGenre;

  const GenreArtist({
    required this.id,
    required this.displayName,
    required this.username,
    required this.profilePicture,
    required this.isVerified,
    required this.followerCount,
    required this.trackCountInGenre,
  });
}
