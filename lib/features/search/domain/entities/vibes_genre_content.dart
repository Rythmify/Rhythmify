import '../../../../core/domain/entities/track.dart';
import 'vibes_genre_info.dart';
import 'vibes_genre_playlist.dart';
import 'vibes_genre_album.dart';
import 'vibes_genre_artists.dart';
import 'vibes_genre_introducing_section.dart';

class GenreContent {
  final GenreInfo genreInfo;
  final IntroducingSection introducing;
  final List<GenrePlaylist> playlists;
  final List<GenreAlbum> albums;
  final List<GenreArtist> artists;
  final List<Track> tracks;

  const GenreContent({
    required this.genreInfo,
    required this.introducing,
    required this.playlists,
    required this.albums,
    required this.artists,
    required this.tracks,
  });
}
