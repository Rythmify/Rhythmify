import '../../../../core/data/models/track_dto.dart';
import '../../domain/entities/library_entities.dart';

/// Data transfer models for the Library feature.
///
/// These models parse API/mock payloads and map them to Library domain entities.
// ── FollowedUser ──────────────────────────────────────────────────────────────

class FollowedUserModel extends FollowedUser {
  const FollowedUserModel({
    required super.id,
    required super.displayName,
    super.username,
    super.avatarUrl,
    required super.followersCount,
    super.isVerified,
  });

  factory FollowedUserModel.fromJson(Map<String, dynamic> json) {
    return FollowedUserModel(
      id: json['id'] as String? ?? json['user_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      username: json['username'] as String?,
      avatarUrl:
          json['profile_picture'] as String? ?? json['avatar_url'] as String?,
      followersCount: json['followers_count'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}

// ── LibraryPlaylist ───────────────────────────────────────────────────────────

class LibraryPlaylistModel extends LibraryPlaylist {
  const LibraryPlaylistModel({
    required super.id,
    required super.name,
    super.description,
    super.coverUrl,
    required super.trackCount,
    required super.likeCount,
    required super.isPublic,
    required super.isOwned,
    required super.createdAt,
  });

  factory LibraryPlaylistModel.fromJson(
    Map<String, dynamic> json, {
    bool isOwned = true,
  }) {
    return LibraryPlaylistModel(
      id: json['playlist_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      trackCount: json['track_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      isPublic: json['is_public'] as bool? ?? true,
      isOwned: isOwned,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ── UploadedTrack ─────────────────────────────────────────────────────────────

class UploadedTrackModel extends UploadedTrack {
  const UploadedTrackModel({
    required super.track,
    required super.isPublic,
    required super.status,
  });

  factory UploadedTrackModel.fromJson(Map<String, dynamic> json) {
    return UploadedTrackModel(
      track: TrackDto.fromJson(json),
      isPublic: json['is_public'] as bool? ?? true,
      status: json['status'] as String? ?? 'ready',
    );
  }
}

// ── LikedTrack ────────────────────────────────────────────────────────────────

class LikedTrackModel extends LikedTrack {
  const LikedTrackModel({required super.track});

  factory LikedTrackModel.fromJson(Map<String, dynamic> json) {
    return LikedTrackModel(track: TrackDto.fromJson(json));
  }
}

// ── TrackInsight ──────────────────────────────────────────────────────────────

class TrackInsightModel extends TrackInsight {
  const TrackInsightModel({
    required super.trackId,
    required super.title,
    super.artworkUrl,
    required super.totalPlays,
    required super.uniqueListeners,
    required super.likes,
    required super.reposts,
    required super.comments,
  });

  factory TrackInsightModel.fromTrack(Map<String, dynamic> json) {
    return TrackInsightModel(
      trackId: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artworkUrl: json['artwork_url'] as String?,
      totalPlays: json['play_count'] as int? ?? 0,
      uniqueListeners: (json['play_count'] as int? ?? 0) ~/ 2, // approx
      likes: json['like_count'] as int? ?? 0,
      reposts: json['repost_count'] as int? ?? 0,
      comments: json['comment_count'] as int? ?? 0,
    );
  }
}

// ── RecentlyPlayedEntry ───────────────────────────────────────────────────────

class RecentlyPlayedEntryModel extends RecentlyPlayedEntry {
  const RecentlyPlayedEntryModel({
    required super.trackId,
    required super.userId,
    required super.title,
    required super.artistName,
    super.artworkUrl,
    super.streamUrl,
    super.audioUrl,
    required super.durationSeconds,
    required super.playCount,
    super.isLiked = false,
    super.isArtistFollowed = false,
    required super.playedAt,
  });

  factory RecentlyPlayedEntryModel.fromJson(Map<String, dynamic> json) {
    // Supports both /me/history and /me/listening-history shapes
    final track = json['track'] as Map<String, dynamic>? ?? json;
    final playedAt =
        json['last_played_at'] as String? ?? json['played_at'] as String?;

    return RecentlyPlayedEntryModel(
      trackId: track['id'] as String? ?? '',
      userId: track['user_id'] as String? ?? '',
      title: track['title'] as String? ?? '',
      artistName:
          track['display_name'] as String? ??
          track['artist_name'] as String? ??
          track['artist'] as String? ??
          '',
      artworkUrl:
          track['artwork_url'] as String? ?? track['cover_image'] as String?,
      streamUrl: track['stream_url'] as String?,
      audioUrl: track['audio_url'] as String?,
      durationSeconds:
          track['duration'] as int? ?? track['duration_seconds'] as int? ?? 0,
      playCount: track['play_count'] as int? ?? 0,
      isLiked:
          track['is_liked'] as bool? ?? track['is_liked_by_me'] as bool? ?? false,
      isArtistFollowed:
          track['is_artist_followed'] as bool? ??
          track['is_artist_followed_by_me'] as bool? ??
          false,
      playedAt: playedAt != null
          ? DateTime.tryParse(playedAt) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ── LibraryStation ────────────────────────────────────────────────────────────

class LibraryStationModel extends LibraryStation {
  const LibraryStationModel({
    required super.id,
    required super.name,
    super.coverUrl,
    required super.seedArtistName,
    required super.trackCount,
  });

  factory LibraryStationModel.fromJson(Map<String, dynamic> json) {
    final seedArtist = json['seed_artist'] as Map<String, dynamic>? ?? {};
    return LibraryStationModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Station',
      coverUrl: json['cover_image'] as String?,
      seedArtistName: seedArtist['display_name'] as String? ?? '',
      trackCount: json['track_count'] as int? ?? 50,
    );
  }
}
