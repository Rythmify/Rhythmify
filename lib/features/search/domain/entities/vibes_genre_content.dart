import '../../../../core/domain/entities/track.dart';
import '../../../profile/domain/entities/profile_entity.dart';

class GenreContent {
  const GenreContent({
    required this.trendingTracks,
    required this.playlists,
    required this.albums,
    required this.profiles,
    required this.discoverTracks,
  });

  final List<Track> trendingTracks;
  final List<Map<String, String>>
  playlists; // {id, title, creatorName, coverImage}
  final List<Map<String, String>> albums; // {id, title, artistName, coverImage}
  final List<ProfileEntity> profiles; // {id, username, avatarUrl}
  final List<Track> discoverTracks;
}
