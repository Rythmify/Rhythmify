import '../../domain/entities/feed_item.dart';

/// Data model for a single feed item, extending [FeedItemEntity].
///
/// Handles JSON deserialization for both regular feed items (tracks and
/// playlists posted or reposted by followed users) and bridges the
/// data layer to the domain layer.
class FeedItemModel extends FeedItemEntity {
  const FeedItemModel({
    required super.id,
    required super.type,
    required super.contentType,
    required super.createdAt,
    required super.user,
    required super.trackOwner,
    required super.track,
    super.playlist,
    super.discoverLabel,
  });

  /// Parses a [FeedItemModel] from a raw JSON map.
  ///
  /// Resolves the track to display by preferring the top-level `track`
  /// field, falling back to the first track inside `playlist.tracks`
  /// if present. Returns `null` if no resolvable track is found.
  ///
  /// The track owner is resolved in order:
  /// `track.user` → `track.artist` → `user`.
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

    final trackOwnerJson =
        resolvedTrack['user'] as Map<String, dynamic>? ??
        resolvedTrack['artist'] as Map<String, dynamic>? ??
        userJson;

    return FeedItemModel(
      id: json['id'] as String,
      type: json['type'] as String,
      contentType: json['content_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: FeedUserModel.fromJson(userJson), // poster/reposter
      trackOwner: FeedUserModel.fromJson(trackOwnerJson), // track owner
      track: FeedTrackModel.fromJson(resolvedTrack),
      playlist: playlistJson != null
          ? FeedPlaylistModel.fromJson(playlistJson)
          : null,
    );
  }
}

/// Data model for a user referenced inside a feed item, extending
/// [FeedUserEntity].
///
/// Covers both the poster/reposter ([FeedItemEntity.user]) and the
/// track owner ([FeedItemEntity.trackOwner]) roles within a feed item.
class FeedUserModel extends FeedUserEntity {
  const FeedUserModel({
    required super.id,
    required super.username,
    required super.displayName,
    super.avatar,
    required super.followers,
    required super.isVerified,
    super.isFollowing,
  });

  /// Parses a [FeedUserModel] from a raw JSON map.
  ///
  /// Falls back to `username` if `displayName` is absent, and accepts
  /// either `profile_picture` or `avatar` as the avatar URL key.
  factory FeedUserModel.fromJson(Map<String, dynamic> json) {
    return FeedUserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['displayName'] as String? ?? json['username'] as String,
      avatar: json['profile_picture'] as String? ?? json['avatar'] as String?,
      followers: json['followers'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }
}

/// Data model for a track referenced inside a feed item, extending
/// [FeedTrackEntity].
///
/// Normalizes inconsistent backend field names (e.g. `audio_url` vs
/// `audioUrl`, `artist` vs `user`) into a single typed entity.
class FeedTrackModel extends FeedTrackEntity {
  const FeedTrackModel({
    required super.id,
    required super.title,
    required super.duration,
    required super.playCount,
    required super.likeCount,
    super.commentCount,
    super.coverUrl,
    required super.audioUrl,
    super.streamUrl,
    super.previewUrl,
    required super.uploaderUsername,
  });

  /// Parses a [FeedTrackModel] from a raw JSON map.
  ///
  /// Resolves the uploader username from either the `artist` or `user`
  /// nested object. Accepts both snake_case and camelCase variants for
  /// URL fields to handle backend inconsistencies.
  factory FeedTrackModel.fromJson(Map<String, dynamic> json) {
    final artistJson =
        (json['artist'] ?? json['user']) as Map<String, dynamic>? ?? {};
    return FeedTrackModel(
      id: json['id'] as String,
      title: json['title'] as String,
      duration: json['duration'] as int? ?? 0,
      playCount: json['play_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      coverUrl: json['cover_image'] as String? ?? json['coverUrl'] as String?,
      audioUrl:
          json['audio_url'] as String? ?? json['audioUrl'] as String? ?? '',
      streamUrl: json['stream_url'] as String? ?? json['streamUrl'] as String?,
      previewUrl:
          json['preview_url'] as String? ?? json['previewUrl'] as String?,
      uploaderUsername: artistJson['username'] as String? ?? '',
    );
  }
}

/// Data model for a playlist referenced inside a feed item, extending
/// [FeedPlaylistEntity].
class FeedPlaylistModel extends FeedPlaylistEntity {
  const FeedPlaylistModel({
    required super.id,
    required super.title,
    super.coverUrl,
    required super.trackCount,
    required super.likeCount,
    required super.repostCount,
  });

  /// Parses a [FeedPlaylistModel] from a raw JSON map.
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
