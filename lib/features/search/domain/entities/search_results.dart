import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';
import '../../../../core/domain/entities/track.dart';
import 'top_result.dart';

/// Holds the results of a search query, grouped by content type.
class SearchResults {
  const SearchResults({
    required this.tracks,
    this.playlists = const [],
    this.profiles = const [],
    this.albums = const [],
    this.topResult,
  });

  final List<Track> tracks;

  /// Raw maps
  final List<Map<String, String>> playlists;

  final List<ProfileEntity> profiles;

  final List<Map<String, String>> albums;

  final TopResult? topResult;
}
