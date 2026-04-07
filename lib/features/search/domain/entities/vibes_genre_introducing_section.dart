import '../../../../core/domain/entities/track.dart';
import 'vibes_genre_introducing_playlist.dart';

class IntroducingSection {
  final IntroducingPlaylist playlist;
  final List<Track> tracksPreview;

  const IntroducingSection({
    required this.playlist,
    required this.tracksPreview,
  });
}
