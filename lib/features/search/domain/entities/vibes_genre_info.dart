/// Metadata for a genre/vibes category, used to populate the page header and stats.
class GenreInfo {
  final String id;
  final String name;

  /// URL or local asset path for the genre's cover/header image.
  final String coverImage;

  final int trackCount;
  final int artistCount;
  final int playlistCount;
  final int albumCount;

  const GenreInfo({
    required this.id,
    required this.name,
    required this.coverImage,
    required this.trackCount,
    required this.artistCount,
    required this.playlistCount,
    required this.albumCount,
  });
}
