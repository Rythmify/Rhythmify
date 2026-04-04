import 'collection_type.dart';

/// Domain entity representing a playlist, album, or station.
///
/// Sourced from `GET /playlists`, `GET /playlists/{id}`, or
/// `POST /playlists`. Station entities are constructed from the
/// `/home/stations` response and set [collectionType] to
/// [CollectionType.station].
///
/// This entity is immutable. Use [copyWith] to produce modified copies.
class PlaylistEntity {
  const PlaylistEntity({
    required this.id,
    required this.ownerUserId,
    required this.name,
    required this.slug,
    required this.isPublic,
    required this.collectionType,
    required this.trackCount,
    required this.likeCount,
    required this.repostCount,
    required this.createdAt,
    this.description,
    this.coverImageUrl,
    this.releaseDate,
    this.genreId,
    this.tags = const [],
    this.secretToken,
    this.updatedAt,
    // Station-only fields — null for playlist/album
    this.seedArtistId,
    this.seedArtistName,
    this.seedArtistAvatarUrl,
  });

  final String id;
  final String ownerUserId;
  final String name;

  /// URL-friendly slug — used to build the share permalink.
  final String slug;

  final bool isPublic;

  /// Discriminator — drives all label, icon, and routing decisions in the UI.
  final CollectionType collectionType;

  final String? description;
  final String? coverImageUrl;
  final String? releaseDate;
  final String? genreId;
  final List<String> tags;

  /// Derived counters — not stored on the backend, computed at query time.
  final int trackCount;
  final int likeCount;
  final int repostCount;

  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Only present when the authenticated user is the playlist owner.
  /// Used to generate the shareable private link.
  final String? secretToken;

  // ── Station-only ──────────────────────────────────────────────────────────

  /// The artist whose catalogue seeds this station.
  /// Only set when [collectionType] is [CollectionType.station].
  final String? seedArtistId;
  final String? seedArtistName;
  final String? seedArtistAvatarUrl;

  // ── Derived helpers ───────────────────────────────────────────────────────

  /// True when this collection was created by the current user.
  /// The caller must pass their own userId to check ownership.
  bool isOwnedBy(String userId) => ownerUserId == userId;

  /// Human-readable label used across cards and headers ("Playlist" / "Album" / "Station").
  String get typeLabel => labelForCollectionType(collectionType);

  // ── copyWith ──────────────────────────────────────────────────────────────

  PlaylistEntity copyWith({
    String? id,
    String? ownerUserId,
    String? name,
    String? slug,
    bool? isPublic,
    CollectionType? collectionType,
    String? description,
    String? coverImageUrl,
    String? releaseDate,
    String? genreId,
    List<String>? tags,
    int? trackCount,
    int? likeCount,
    int? repostCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? secretToken,
    String? seedArtistId,
    String? seedArtistName,
    String? seedArtistAvatarUrl,
    bool clearCover = false,
    bool clearSecret = false,
  }) {
    return PlaylistEntity(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      isPublic: isPublic ?? this.isPublic,
      collectionType: collectionType ?? this.collectionType,
      description: description ?? this.description,
      coverImageUrl: clearCover ? null : (coverImageUrl ?? this.coverImageUrl),
      releaseDate: releaseDate ?? this.releaseDate,
      genreId: genreId ?? this.genreId,
      tags: tags ?? this.tags,
      trackCount: trackCount ?? this.trackCount,
      likeCount: likeCount ?? this.likeCount,
      repostCount: repostCount ?? this.repostCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      secretToken: clearSecret ? null : (secretToken ?? this.secretToken),
      seedArtistId: seedArtistId ?? this.seedArtistId,
      seedArtistName: seedArtistName ?? this.seedArtistName,
      seedArtistAvatarUrl: seedArtistAvatarUrl ?? this.seedArtistAvatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaylistEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}