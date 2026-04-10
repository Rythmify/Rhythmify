class GenreInfo {
  final String id;
  final String name;
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
