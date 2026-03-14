import '../../domain/entities/track_entity.dart';

class TrackModel extends TrackEntity {
  const TrackModel({
    required super.id,
    required super.title,
    required super.artistName,
    super.artworkUrl,
    required super.playCount,
    required super.durationSeconds,
    required super.isLiked,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      artistName: json['user']?['display_name'] as String? ?? '',
      artworkUrl: json['artwork_url'] as String?,
      playCount: json['play_count'] as int? ?? 0,
      durationSeconds: json['duration'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist_name': artistName,
      'artwork_url': artworkUrl,
      'play_count': playCount,
      'duration': durationSeconds,
      'is_liked': isLiked,
    };
  }
}