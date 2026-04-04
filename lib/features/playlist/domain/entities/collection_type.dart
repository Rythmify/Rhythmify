/// Discriminates between the three collection UI types in Rythmify.
///
/// - [playlist] → regular user-created playlist (`subtype: playlist` from API).
/// - [album]    → artist album/EP/single/compilation (`subtype: album|ep|single|compilation`).
/// - [station]  → artist-seeded radio station (sourced from `/home/stations`, not `/playlists`).
///
/// Used by [PlaylistCardWidget], [PlaylistDetailScreen], and routing to render
/// the correct labels, icons, and behaviour without duplicating UI code.
enum CollectionType { playlist, album, station }

/// Maps an API `subtype` string from `POST /playlists` or `GET /playlists`
/// to the Flutter [CollectionType] enum.
///
/// Album subtypes (`album`, `ep`, `single`, `compilation`) all render as
/// [CollectionType.album] in the UI. Stations never come through this path —
/// they are constructed directly with [CollectionType.station].
CollectionType collectionTypeFromSubtype(String? subtype) {
  switch (subtype) {
    case 'album':
    case 'ep':
    case 'single':
    case 'compilation':
      return CollectionType.album;
    case 'playlist':
    default:
      return CollectionType.playlist;
  }
}

/// Returns the raw API `subtype` string for a given [CollectionType].
/// Used when sending [CreatePlaylistRequest] or [UpdatePlaylistRequest].
///
/// Note: [CollectionType.station] has no API subtype — stations are read-only
/// from the Home & Discovery endpoints.
String subtypeFromCollectionType(CollectionType type) {
  switch (type) {
    case CollectionType.album:
      return 'album';
    case CollectionType.playlist:
    case CollectionType.station:
      return 'playlist';
  }
}

/// Human-readable label shown in the UI for each [CollectionType].
/// Matches SoundCloud's naming convention.
String labelForCollectionType(CollectionType type) {
  switch (type) {
    case CollectionType.playlist:
      return 'Playlist';
    case CollectionType.album:
      return 'Album';
    case CollectionType.station:
      return 'Station';
  }
}