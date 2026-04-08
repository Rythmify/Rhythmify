class GenreAlbum {
  final String id;
  final String name;
  final String coverImage;
  final String ownerId;
  final String ownerName;
  final int trackCount;
  final int likeCount;
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
