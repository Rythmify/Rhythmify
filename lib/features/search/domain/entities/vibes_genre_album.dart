/// Represents an album entry displayed on a genre/vibes page.
class GenreAlbum {
  final String id;
  final String name;
  final String coverImage;
  final String ownerId;
  final String ownerName;
  final int trackCount;
  final int likeCount;

  /// Release date as an ISO 8601 string (e.g. `'2026-01-01'`).
  final String releaseDate;

  const GenreAlbum({
    required this.id,
    required this.name,
    required this.coverImage,
    required this.ownerId,
    required this.ownerName,
    required this.trackCount,
    required this.likeCount,
    required this.releaseDate,
  });
}
