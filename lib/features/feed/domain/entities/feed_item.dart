/// Represents a single item in the feed (post or repost of a track or playlist).
class FeedItemEntity {
  final String id;

  /// Either 'post' or 'repost'.
  final String type;

  /// Either 'track' or 'playlist'.
  final String contentType;

  final DateTime createdAt;
  final FeedUserEntity user;

  /// Always non-null — for playlist posts this is the featured track.
  final FeedTrackEntity track;

  /// Only present when contentType == 'playlist'.
  final FeedPlaylistEntity? playlist;

  const FeedItemEntity({
    required this.id,
    required this.type,
    required this.contentType,
    required this.createdAt,
    required this.user,
    required this.track,
    this.playlist,
  });
}

class FeedUserEntity {
  final String id;
  final String username;
  final String displayName;
  final String? avatar;
  final int followers;
  final bool isVerified;

  const FeedUserEntity({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatar,
    required this.followers,
    required this.isVerified,
  });
}

class FeedTrackEntity {
  final String id;
  final String title;
  final int duration;
  final int playCount;
  final int likeCount;
  final String? coverUrl;
  final String audioUrl;
  final String uploaderUsername;

  const FeedTrackEntity({
    required this.id,
    required this.title,
    required this.duration,
    required this.playCount,
    required this.likeCount,
    this.coverUrl,
    required this.audioUrl,
    required this.uploaderUsername,
  });
}

class FeedPlaylistEntity {
  final String id;
  final String title;
  final String? coverUrl;
  final int trackCount;
  final int likeCount;
  final int repostCount;

  const FeedPlaylistEntity({
    required this.id,
    required this.title,
    this.coverUrl,
    required this.trackCount,
    required this.likeCount,
    required this.repostCount,
  });
}
