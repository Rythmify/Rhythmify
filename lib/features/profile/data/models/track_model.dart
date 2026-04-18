import '../../../../core/domain/entities/track.dart';

/// Track model used by profile liked-tracks and profile track lists.
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
    super.artistPfp,
    super.releaseDate,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = json;

    return TrackModel(
      id: data['id'] as String? ?? '',
      userId:
          data['user_id'] as String? ?? data['user']?['id'] as String? ?? '',
      title: data['title'] as String? ?? '',
      artist:
          data['display_name'] as String? ??
          data['artist_name'] as String? ??
          data['user']?['display_name'] as String? ??
          data['artist'] as String? ??
          '',
      artistPfp:
          data['profile_picture'] as String? ??
          data['user']?['profile_picture'] as String? ??
          data['artist_pfp'] as String?,
      audioUrl:
          data['stream_url'] as String? ?? data['audio_url'] as String? ?? '',
      streamUrl: data['stream_url'] as String?,
      duration: Duration(
        seconds: data['duration'] as int? ?? data['duration_seconds'] as int? ?? 0,
      ),
      createdAt: DateTime.tryParse(
            data['liked_at'] as String? ??
                data['created_at'] as String? ??
                '',
          ) ??
          DateTime.now(),
      coverImage:
          data['cover_image'] as String? ?? data['artwork_url'] as String?,
      description: data['description'] as String?,
      playCount: data['play_count'] as int? ?? 0,
      likeCount: data['like_count'] as int? ?? 0,
      commentCount: data['comment_count'] as int? ?? 0,
      repostCount: data['repost_count'] as int? ?? 0,
      isLiked: data['is_liked'] as bool? ?? true,
      isArtistFollowed: data['is_artist_followed'] as bool? ?? false,
      status: data['status'] as String?,
      releaseDate: data['release_date'] as String?,
      genre: data['genre'] as String?,
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
