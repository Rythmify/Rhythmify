import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';

import '../../../../core/domain/entities/track.dart';

class SearchResults {
  const SearchResults({
    required this.tracks,
    this.playlists = const [],
    this.profiles = const [],
    this.albums = const [],
  });

  final List<Track> tracks;
  final List<dynamic> playlists; // replace dynamic with Playlist when ready
  final List<ProfileEntity> profiles;
  final List<dynamic> albums; // replace dynamic with Album when ready
}
