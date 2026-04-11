import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';
import '../../../../core/domain/entities/track.dart';

/// Holds the results of a search query, grouped by content type.
class SearchResults {
  const SearchResults({
    required this.tracks,
    this.playlists = const [],
    this.profiles = const [],
    this.albums = const [],
  });

  final List<Track> tracks;

  /// Raw maps until a teammate-owned Playlist entity is available.
  final List<Map<String, String>>
  playlists; // swap to PlaylistEntity when ready

  final List<ProfileEntity> profiles;

  /// Raw maps until a teammate-owned Album entity is available.
  final List<Map<String, String>> albums; // swap to AlbumEntity when ready
}
