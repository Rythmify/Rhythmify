class GenreArtist {
  final String id;
  final String displayName;
  final String username;
  final String profilePicture;
  final bool isVerified;
  final int followerCount;
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
