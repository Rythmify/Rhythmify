import '../../domain/entities/feed_item.dart';

class FeedItemModel extends FeedItemEntity {
  const FeedItemModel({
    required super.id,
    required super.type,
    required super.contentType,
    required super.createdAt,
    required super.user,
    required super.track,
    super.playlist,
    super.discoverLabel,
  });

  static FeedItemModel? fromJson(Map<String, dynamic> json) {
    final trackJson = json['track'] as Map<String, dynamic>?;
    final playlistJson = json['playlist'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>;

    final resolvedTrack =
        trackJson ??
        (playlistJson?['tracks'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .firstOrNull;

    if (resolvedTrack == null) return null;

    return FeedItemModel(
      id: json['id'] as String,
      type: json['type'] as String,
      contentType: json['content_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: FeedUserModel.fromJson(userJson),
      track: FeedTrackModel.fromJson(resolvedTrack),
      playlist: playlistJson != null
          ? FeedPlaylistModel.fromJson(playlistJson)
          : null,
    );
  }
}

class FeedUserModel extends FeedUserEntity {
  const FeedUserModel({
    required super.id,
    required super.username,
    required super.displayName,
    super.avatar,
    required super.followers,
    required super.isVerified,
  });

  factory FeedUserModel.fromJson(Map<String, dynamic> json) {
    return FeedUserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String? ?? json['username'] as String,
      avatar: json['avatar'] as String?,
      followers: json['followers'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}

class FeedTrackModel extends FeedTrackEntity {
  const FeedTrackModel({
    required super.id,
    required super.title,
    required super.duration,
    required super.playCount,
    required super.likeCount,
    super.coverUrl,
    required super.audioUrl,
    super.streamUrl, // add
    required super.uploaderUsername,
  });

  factory FeedTrackModel.fromJson(Map<String, dynamic> json) {
    final artistJson =
        (json['artist'] ?? json['user']) as Map<String, dynamic>? ?? {};
    return FeedTrackModel(
      id: json['id'] as String,
      title: json['title'] as String,
      duration: json['duration'] as int? ?? 0,
      playCount: json['play_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      coverUrl: json['cover_image'] as String? ?? json['coverUrl'] as String?,
      audioUrl:
          json['audio_url'] as String? ?? json['audioUrl'] as String? ?? '',
      streamUrl:
          json['stream_url'] as String? ?? json['streamUrl'] as String?, // add
      uploaderUsername: artistJson['username'] as String? ?? '',
    );
  }
}

class FeedPlaylistModel extends FeedPlaylistEntity {
  const FeedPlaylistModel({
    required super.id,
    required super.title,
    super.coverUrl,
    required super.trackCount,
    required super.likeCount,
    required super.repostCount,
  });

  factory FeedPlaylistModel.fromJson(Map<String, dynamic> json) {
    return FeedPlaylistModel(
      id: json['id'] as String,
      title: json['title'] as String,
      coverUrl: json['coverUrl'] as String?,
      trackCount: json['trackCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      repostCount: json['repostCount'] as int? ?? 0,
    );
  }
}
