import '../../../../core/domain/entities/track.dart';

class IntroducingPlaylist {
  final String playlistId;
  final String ownerUserId;
  final String name;
  final String description;
  final bool isPublic;
  final DateTime createdAt;
  final int trackCount;
  final int likeCount;
  final String coverImage;
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
