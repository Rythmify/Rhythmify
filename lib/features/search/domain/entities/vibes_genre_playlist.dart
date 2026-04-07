class GenrePlaylist {
  final String id;
  final String name;
  final String coverImage;
  final String ownerId;
  final String ownerName;
  final int trackCount;
  final int likeCount;
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
