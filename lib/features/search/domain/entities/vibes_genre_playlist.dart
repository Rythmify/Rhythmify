/// Represents a playlist entry displayed on a genre/vibes page.
class GenrePlaylist {
  final String id;
  final String name;
  final String coverImage;
  final String ownerId;
  final String ownerName;
  final int trackCount;
  final int likeCount;

  /// Indicates how this playlist was associated with the genre (e.g. `'tagged'`, `'curated'`).
  final String source;

  final DateTime createdAt;

  const GenrePlaylist({
    required this.id,
    required this.name,
    required this.coverImage,
    required this.ownerId,
    required this.ownerName,
    required this.trackCount,
    required this.likeCount,
    required this.source,
    required this.createdAt,
  });
}
