// lib/features/playlist/domain/entities/playlist_entity.dart
/// This file defines the PlaylistEntity domain model used throughout the
/// playlist feature.
///
/// Features:
/// - Represents playlists, albums, and stations
/// - Stores playlist metadata and ownership information
/// - Provides formatted/computed helper getters
/// - Supports immutable updates using copyWith()
///
/// Main Components:
/// - PlaylistType:
///     Enum representing playlist, album, or station.
///
/// - PlaylistEntity:
///     Main playlist domain entity.
///
/// Computed Getters:
/// - typeLabel:
///     Returns formatted playlist type label.
///
/// - detailSubtitle:
///     Returns subtitle text for detail screens.
///
/// - subtitleLine:
///     Returns formatted subtitle text for lists/cards.
///
/// Methods:
/// - copyWith():
///     Creates a modified copy of the entity.
///
/// Dependencies:
/// - None
library;

enum PlaylistType { playlist, album, station }

class PlaylistEntity {
  const PlaylistEntity({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.ownerId,
    required this.isPublic,
    required this.type,
    required this.trackCount,
    required this.totalDuration,
    required this.createdAt,
    this.coverUrl,
    this.description,
    this.likeCount = 0,
    this.repostCount = 0,
    this.isLiked = false,
    this.isOwned = false,
    this.isGeneratedMix = false,
    this.isTrackRadio = false,
    this.seedArtistName,
    this.releaseYear,
  });

  final String id;
  final String name;
  final String ownerName;
  final String ownerId;
  final bool isPublic;
  final PlaylistType type;
  final int trackCount;
  final Duration totalDuration;
  final DateTime createdAt;
  final String? coverUrl;
  final String? description;
  final int likeCount;
  final int repostCount;
  final bool isLiked;
  final bool isOwned;
  final bool isGeneratedMix;
  final bool isTrackRadio;
  final String? seedArtistName;
  final int? releaseYear;

  // ── Computed getters ──────────────────────────────────────────────────────

  String get typeLabel {
    if (isGeneratedMix) return 'Mix';
    if (isTrackRadio) return 'Radio';
    switch (type) {
      case PlaylistType.playlist:
        return 'Playlist';
      case PlaylistType.album:
        return 'Album';
      case PlaylistType.station:
        return 'Station';
    }
  }

  String get detailSubtitle {
    switch (type) {
      case PlaylistType.playlist:
        return '$trackCount tracks';
      case PlaylistType.album:
        return 'Album · $trackCount tracks';
      case PlaylistType.station:
        return 'Station · $trackCount tracks';
    }
  }

  String get subtitleLine {
    if (isGeneratedMix) return 'Mix · $trackCount tracks';
    if (isTrackRadio) return 'Radio · $trackCount tracks';
    switch (type) {
      case PlaylistType.playlist:
        return 'Playlist · $trackCount tracks';
      case PlaylistType.album:
        return 'Album · $trackCount tracks';
      case PlaylistType.station:
        return 'Station · $trackCount tracks';
    }
  }

  PlaylistEntity copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? ownerId,
    bool? isPublic,
    PlaylistType? type,
    int? trackCount,
    Duration? totalDuration,
    DateTime? createdAt,
    String? coverUrl,
    bool clearCover = false,
    String? description,
    int? likeCount,
    int? repostCount,
    bool? isLiked,
    bool? isOwned,
    bool? isGeneratedMix,
    bool? isTrackRadio,
    String? seedArtistName,
    int? releaseYear,
  }) {
    return PlaylistEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      ownerId: ownerId ?? this.ownerId,
      isPublic: isPublic ?? this.isPublic,
      type: type ?? this.type,
      trackCount: trackCount ?? this.trackCount,
      totalDuration: totalDuration ?? this.totalDuration,
      createdAt: createdAt ?? this.createdAt,
      coverUrl: clearCover ? null : (coverUrl ?? this.coverUrl),
      description: description ?? this.description,
      likeCount: likeCount ?? this.likeCount,
      repostCount: repostCount ?? this.repostCount,
      isLiked: isLiked ?? this.isLiked,
      isOwned: isOwned ?? this.isOwned,
      isGeneratedMix: isGeneratedMix ?? this.isGeneratedMix,
      isTrackRadio: isTrackRadio ?? this.isTrackRadio,
      seedArtistName: seedArtistName ?? this.seedArtistName,
      releaseYear: releaseYear ?? this.releaseYear,
    );
  }
}
