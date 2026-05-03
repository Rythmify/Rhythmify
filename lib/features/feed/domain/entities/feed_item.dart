/// Represents a feed item entity in the domain layer.
class FeedItemEntity {
  final String id;
  final String type;
  final String contentType;
  final DateTime createdAt;
  final FeedUserEntity user; // poster/reposter
  final FeedUserEntity
  trackOwner; // track owner (may be same as user for posts)
  final FeedTrackEntity track;
  final FeedPlaylistEntity? playlist;
  final String? discoverLabel;

  const FeedItemEntity({
    required this.id,
    required this.type,
    required this.contentType,
    required this.createdAt,
    required this.user,
    required this.trackOwner,
    required this.track,
    this.playlist,
    this.discoverLabel,
  });
}

/// Represents feed user in the domain layer.
class FeedUserEntity {
  final String id;
  final String username;
  final String displayName;
  final String? avatar;
  final int followers;
  final bool isVerified;
  final bool isFollowing;

  const FeedUserEntity({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatar,
    required this.followers,
    required this.isVerified,
    this.isFollowing = false,
  });
}

/// Represents feed track in the domain layer.
class FeedTrackEntity {
  final String id;
  final String title;
  final int duration;
  final int playCount;
  final int likeCount;
  final int commentCount;
  final String? coverUrl;
  final String audioUrl;
  final String? streamUrl;
  final String? previewUrl;
  final String uploaderUsername;

  const FeedTrackEntity({
    required this.id,
    required this.title,
    required this.duration,
    required this.playCount,
    required this.likeCount,
    this.commentCount = 0,
    this.coverUrl,
    required this.audioUrl,
    this.streamUrl,
    this.previewUrl,
    required this.uploaderUsername,
  });
}

/// Represents  feed playlist in the domain layer.
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
