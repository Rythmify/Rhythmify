import '../../../../core/domain/entities/track.dart';
// import '../../../playlist/domain/entities/playlist.dart';  // uncomment when ready
// import '../../../profile/domain/entities/profile.dart';
// import '../../../album/domain/entities/album.dart';

class SearchResults {
  const SearchResults({
    required this.tracks,
    this.playlists = const [],
    this.profiles = const [],
    this.albums = const [],
  });

  final List<Track> tracks;
  final List<dynamic> playlists; // replace dynamic with Playlist when ready
  final List<dynamic> profiles; // replace dynamic with Profile when ready
  final List<dynamic> albums; // replace dynamic with Album when ready
}
