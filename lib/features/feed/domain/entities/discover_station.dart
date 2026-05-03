/// Represents a [DiscoverStation] in the domain layer.
class StationImages {
  final String? left;
  final String? center;
  final String? right;

  const StationImages({this.left, this.center, this.right});
}

class DiscoverStation {
  final String id;
  final String name;
  final String artistId;
  final String artistName;
  final String coverImage;
  final int trackCount;
  final int followerCount;
  final StationImages images;

  const DiscoverStation({
    required this.id,
    required this.name,
    required this.artistId,
    required this.artistName,
    required this.coverImage,
    required this.trackCount,
    required this.followerCount,
    this.images = const StationImages(), // ← default empty
  });
}
