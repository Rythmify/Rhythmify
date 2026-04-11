import '../../../../core/domain/entities/track.dart';
import 'vibes_genre_introducing_playlist.dart';

/// The "Introducing" section shown at the top of a genre page.
/// Contains a featured playlist and a short list of preview tracks.
class IntroducingSection {
  final IntroducingPlaylist playlist;

  /// A small selection of tracks previewed below the featured playlist.
  final List<Track> tracksPreview;

  const IntroducingSection({
    required this.playlist,
    required this.tracksPreview,
  });
}
