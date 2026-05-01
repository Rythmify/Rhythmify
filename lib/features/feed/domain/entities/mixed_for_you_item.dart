import '../../../../core/domain/entities/track.dart';

/// Represents a mixed for you item in the domain layer.
class MixedForYouItem {
  final String id;
  final String label;
  final String flavor;
  final String genreName;
  final String coverImage;
  final int trackCount;
  final DateTime generatedAt;
  final Track previewTrack;

  const MixedForYouItem({
    required this.id,
    required this.label,
    required this.flavor,
    required this.genreName,
    required this.coverImage,
    required this.trackCount,
    required this.generatedAt,
    required this.previewTrack,
  });
}
