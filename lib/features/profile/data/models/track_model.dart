import '../../../../core/domain/entities/track.dart';

class TrackModel extends Track {
  const TrackModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.artist,
    required super.audioUrl,
    required super.duration,
    required super.createdAt,
    super.description,
    super.coverImage,
    super.streamUrl,
    super.playCount,
    super.likeCount,
    super.commentCount,
    super.repostCount,
    super.isLiked,
    super.isReposted,
    super.isArtistFollowed,
    super.tags,
    super.waveformData,
    super.genre,
    super.isTrending,
    super.isFeatured,
    super.updatedAt,
    super.status,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] as String? ?? '',
      userId:
          json['user']?['id'] as String? ?? json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist:
          json['user']?['display_name'] as String? ??
          json['artist'] as String? ??
          '',
      audioUrl:
          json['stream_url'] as String? ?? json['audio_url'] as String? ?? '',
      duration: Duration(seconds: json['duration'] as int? ?? 0),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      coverImage:
          json['artwork_url'] as String? ?? json['cover_image'] as String?,
      description: json['description'] as String?,
      playCount: json['play_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isArtistFollowed: json['is_artist_followed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'artist': artist,
      'artwork_url': coverImage,
      'audio_url': audioUrl,
      'duration': duration.inSeconds,
      'play_count': playCount,
      'is_liked': isLiked,
      'is_artist_followed': isArtistFollowed,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
