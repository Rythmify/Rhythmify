import 'package:equatable/equatable.dart';
import '../../../../core/domain/entities/track.dart';
import '../../../../core/data/models/track_dto.dart';

// coverage:ignore-file
/// Domain entities used by Library pages, use cases, and repositories.
// ─────────────────────────────────────────────
// FollowedUser — used in Following page
// ─────────────────────────────────────────────
class FollowedUser extends Equatable {
  final String id;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final int followersCount;
  final bool isVerified;

  const FollowedUser({
    required this.id,
    required this.displayName,
    this.username,
    this.avatarUrl,
    required this.followersCount,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
    id,
    displayName,
    avatarUrl,
    followersCount,
    isVerified,
  ];
}

// ─────────────────────────────────────────────
// LibraryPlaylist — used in Playlists page
// ─────────────────────────────────────────────
class LibraryPlaylist extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final int trackCount;
  final int likeCount;
  final bool isPublic;
  final bool isOwned; // true = created by me, false = saved/liked
  final DateTime createdAt;

  const LibraryPlaylist({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    required this.trackCount,
    required this.likeCount,
    required this.isPublic,
    required this.isOwned,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, trackCount, isOwned];
}

// ─────────────────────────────────────────────
// UploadedTrack — used in Your Uploads page
// ─────────────────────────────────────────────
class UploadedTrack extends Equatable {
  final Track track;
  final bool isPublic;
  final String status; // "ready" | "processing" | "failed"

  const UploadedTrack({
    required this.track,
    required this.isPublic,
    required this.status,
  });

  String get id => track.id;
  String get title => track.title;
  String? get artworkUrl => track.coverImage;
  int get playCount => track.playCount;
  int get likeCount => track.likeCount;
  DateTime get createdAt => track.createdAt;

  bool get isProcessing => status == 'processing';
  bool get isFailed => status == 'failed';
  bool get isReady => status == 'ready';

  @override
  List<Object?> get props => [id, title, status, isPublic];
}

// ─────────────────────────────────────────────
// DownloadedTrack — used in Downloads page
// ─────────────────────────────────────────────
class DownloadedTrack extends Equatable {
  final Track track;
  final String localPath;
  final DateTime downloadedAt;

  const DownloadedTrack({
    required this.track,
    required this.localPath,
    required this.downloadedAt,
  });

  String get id => track.id;
  String get title => track.title;
  String? get artworkUrl => track.coverImage;

  @override
  List<Object?> get props => [id, localPath, downloadedAt];

  Map<String, dynamic> toJson() {
    return {
      'track': TrackDto.toJson(track),
      'local_path': localPath,
      'downloaded_at': downloadedAt.toIso8601String(),
    };
  }

  factory DownloadedTrack.fromJson(Map<dynamic, dynamic> json) {
    return DownloadedTrack(
      track: TrackDto.fromJson(
        Map<dynamic, dynamic>.from(json['track'] as Map),
      ),
      localPath: json['local_path'] as String? ?? '',
      downloadedAt:
          DateTime.tryParse(json['downloaded_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
// LikedTrack — used in Your Likes page
// ─────────────────────────────────────────────
class LikedTrack extends Equatable {
  final Track track;

  const LikedTrack({required this.track});

  String get id => track.id;
  String get title => track.title;
  String? get artworkUrl => track.coverImage;
  int get playCount => track.playCount;
  int get likeCount => track.likeCount;
  DateTime get createdAt => track.createdAt;

  @override
  List<Object?> get props => [id, title];
}

// ─────────────────────────────────────────────
// TrackInsight — used in Your Insights page
// ─────────────────────────────────────────────
class TrackInsight extends Equatable {
  final String trackId;
  final String title;
  final String? artworkUrl;
  final int totalPlays;
  final int uniqueListeners;
  final int likes;
  final int reposts;
  final int comments;

  const TrackInsight({
    required this.trackId,
    required this.title,
    this.artworkUrl,
    required this.totalPlays,
    required this.uniqueListeners,
    required this.likes,
    required this.reposts,
    required this.comments,
  });

  @override
  List<Object?> get props => [trackId, totalPlays];
}

// ─────────────────────────────────────────────
// RecentlyPlayedEntry — Listening History
// ─────────────────────────────────────────────
class RecentlyPlayedEntry extends Equatable {
  final String trackId;
  final String userId;
  final String title;
  final String artistName;
  final String? artworkUrl;
  final String? streamUrl;
  final String? audioUrl;
  final int durationSeconds;
  final int playCount;
  final bool isLiked;
  final bool isArtistFollowed;
  final DateTime playedAt;

  const RecentlyPlayedEntry({
    required this.trackId,
    required this.userId,
    required this.title,
    required this.artistName,
    this.artworkUrl,
    this.streamUrl,
    this.audioUrl,
    required this.durationSeconds,
    required this.playCount,
    this.isLiked = false,
    this.isArtistFollowed = false,
    required this.playedAt,
  });

  @override
  List<Object?> get props => [trackId, playedAt, userId, playCount];
}

// ─────────────────────────────────────────────
// LibraryStation — used in Stations page
// ─────────────────────────────────────────────
class LibraryStation extends Equatable {
  final String id;
  final String name;
  final String? coverUrl;
  final String seedArtistName;
  final int trackCount;

  const LibraryStation({
    required this.id,
    required this.name,
    this.coverUrl,
    required this.seedArtistName,
    required this.trackCount,
  });

  @override
  List<Object?> get props => [id, name];
}
