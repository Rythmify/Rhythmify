import 'hot_for_you.dart';
import 'trending_by_genre_initial.dart';
import 'mixed_for_you_item.dart';
import 'discover_station.dart';
import '../../../../core/domain/entities/track.dart';

class HomeData {
  final HotForYou hotForYou;
  final TrendingByGenreInitial trendingByGenre;
  final List<Track> moreOfWhatYouLike;
  final List<MixedForYouItem> mixedForYou;
  final List<DiscoverStation> discoverWithStations;

  const HomeData({
    required this.hotForYou,
    required this.trendingByGenre,
    required this.moreOfWhatYouLike,
    required this.mixedForYou,

    required this.discoverWithStations,
  });
}
