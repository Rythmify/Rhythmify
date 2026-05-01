import 'genre_tab.dart';
import 'genre_tab_tracks.dart';

/// Represents the initial genre tab in the domain layer.
class TrendingByGenreInitial {
  final List<GenreTab> genres;
  final GenreTabTracks initialTab;

  const TrendingByGenreInitial({
    required this.genres,
    required this.initialTab,
  });
}
