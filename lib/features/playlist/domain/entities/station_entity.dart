/// Domain entity for an artist-seeded radio station.
///
/// Stations are sourced from `GET /home/stations` and
/// `GET /home/stations/{artist_id}/tracks`. They are NOT playlists — they
/// have no CRUD, no ownership, and are computed on-the-fly by the backend
/// from listening history and social graph data.
///
/// Stations share [PlaylistDetailScreen] with playlists and albums, but
/// the screen detects [CollectionType.station] and hides edit/delete controls.
class StationEntity {
  const StationEntity({
    required this.id,
    required this.name,
    required this.seedArtistId,
    required this.seedArtistDisplayName,
    required this.trackCount,
    this.coverImageUrl,
    this.seedArtistAvatarUrl,
  });

  /// Deterministic UUID derived from [seedArtistId] by the backend.
  final String id;

  /// Display name, e.g. "Based on SZA".
  final String name;

  final String seedArtistId;
  final String seedArtistDisplayName;
  final String? seedArtistAvatarUrl;
  final String? coverImageUrl;
  final int trackCount;

  /// Converts this station to a [PlaylistEntity] shell so the shared
  /// [PlaylistDetailScreen] can consume a single entity type.
  ///
  /// The resulting entity has [CollectionType.station] set and marks
  /// ownership as the seed artist — edit/delete controls are hidden by
  /// checking the type, not ownership.
}
