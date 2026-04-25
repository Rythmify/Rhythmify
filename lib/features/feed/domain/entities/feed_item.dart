class FeedItemEntity {
  final String id;
  final String type;
  final String contentType;
  final DateTime createdAt;
  final FeedUserEntity user;
  final FeedTrackEntity track;
  final FeedPlaylistEntity? playlist;
  final String? discoverLabel;

  const FeedItemEntity({
    required this.id,
    required this.type,
    required this.contentType,
    required this.createdAt,
    required this.user,
    required this.track,
    this.playlist,
    this.discoverLabel,
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
  final String? streamUrl; // added
  final String uploaderUsername;

  const FeedTrackEntity({
    required this.id,
    required this.title,
    required this.duration,
    required this.playCount,
    required this.likeCount,
    this.coverUrl,
    required this.audioUrl,
    this.streamUrl, // added
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
