import '../../../../core/domain/entities/track.dart';

/// The featured playlist shown in the "Introducing" section at the top of a genre page.
class IntroducingPlaylist {
  final String playlistId;
  final String ownerUserId;
  final String name;
  final String description;
  final bool isPublic;
  final DateTime createdAt;
  final int trackCount;
  final int likeCount;

  /// URL or local asset path for the playlist's cover image.
  final String coverImage;

  /// A single track displayed as a preview inside the Introducing section.
  final Track previewTrack;

  const IntroducingPlaylist({
    required this.playlistId,
    required this.ownerUserId,
    required this.name,
    required this.description,
    required this.isPublic,
    required this.createdAt,
    required this.trackCount,
    required this.likeCount,
    required this.coverImage,
    required this.previewTrack,
  });
}
