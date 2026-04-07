import '../../../../core/domain/entities/track.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/genre_tab_tracks.dart';
import '../../domain/entities/hot_for_you.dart';
import '../../domain/entities/mixed_for_you_item.dart';
import '../../domain/entities/discover_station.dart';

/// Contract for fetching home screen data.
///
/// This abstract class defines the **business-level operations**
/// required by the Home feature.
///
/// It acts as a boundary between:
/// - The **domain layer** (use cases / UI logic)
/// - The **data layer** (repository implementations, APIs, local storage)
///
/// Any implementation (e.g., API-based, local JSON, mock data)
/// must implement this interface.
abstract class HomeRepository {
  Future<HomeData> getHomeData();
  Future<GenreTabTracks> getTrendingByGenre(String genreId);
  Future<HotForYou> getHotForYou();
  Future<List<Track>> getMoreOfWhatYouLike();
  Future<List<MixedForYouItem>> getMixedForYou();
  Future<List<DiscoverStation>> getDiscoverStations();
}
