import '../../../feed/domain/repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';
import '../datasources/home_datasource.dart';

/// Implementation of the [HomeRepository] interface.
///
/// This class acts as the **data layer bridge** between:
/// - The **domain layer** (use cases / business logic)
/// - The **data source layer** (local assets, APIs, etc.)
///
/// It delegates all data-fetching responsibilities to [HomeDatasource].
/// This abstraction allows:
/// - Easier testing (mocking the repository)
/// - Flexibility to swap data sources (e.g., API instead of local JSON)
class HomeRepositoryImpl implements HomeRepository {
  /// The data source responsible for retrieving raw data.
  final HomeDatasource datasource;

  /// Creates an instance of [HomeRepositoryImpl].
  ///
  /// [datasource] is injected to allow dependency inversion and easier testing.
  HomeRepositoryImpl(this.datasource);

  /// Fetches trending tracks based on a given genre.
  ///
  /// Currently, the genre parameter is not used for filtering,
  /// since the mock data does not include genre-specific fields.
  ///
  /// Returns a list of [Track] objects.
  @override
  Future<List<Track>> getTrendingTracks(String genre) {
    return datasource.getTrendingTracks(genre);
  }

  /// Fetches tracks for the "Hot For You" section.
  ///
  /// Returns a  [Track] object representing popular or featured track.
  @override
  Future<List<Track>> getHotTracks() {
    return datasource.getHotTracks();
  }

  /// Fetches playlists for the "Mixed For You" section.
  ///
  /// Each playlist is represented as a map containing:
  /// - `mixLabel`: The label of the mix (e.g., MIX 1)
  /// - `image`: The image path (asset or URL)
  /// - `artists`: The associated artist names
  ///
  /// Returns a list of playlist maps.
  @override
  Future<List<Map<String, dynamic>>> getMixedPlaylists() {
    return datasource.getMixedPlaylists();
  }

  /// Fetches station playlists for the "Discover with Stations" section.
  ///
  /// Each station contains:
  /// - `image`: The station artwork
  /// - `artists`: The related artists
  ///
  /// Returns a list of station maps.
  @override
  Future<List<Map<String, dynamic>>> getStationPlaylists() {
    return datasource.getStationPlaylists();
  }

  /// Fetches playlists for the "More of What You Like" section.
  ///
  /// Each item contains:
  /// - `image`: Playlist artwork
  /// - `artists`: Related artist names
  ///
  /// Returns a list of playlist maps.
  @override
  Future<List<Map<String, dynamic>>> getMoreOfWhatYouLikePlaylists() {
    return datasource.getMoreOfWhatYouLikePlaylists();
  }
}
