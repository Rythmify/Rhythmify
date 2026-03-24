import '../../../../core/domain/entities/track.dart';

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
  /// Retrieves a list of trending tracks based on a given genre.
  ///
  /// [genre] specifies the category of music to filter tracks.
  ///
  /// Returns a list of [Track] entities.
  Future<List<Track>> getTrendingTracks(String genre);

  /// Retrieves tracks for the "Hot For You" section.
  ///
  /// This track is typically personalized or a popular track.
  ///
  /// Returns a [Track] entity.
  Future<List<Track>> getHotTracks();

  /// Retrieves playlists for the "Mixed For You" section.
  ///
  /// Each playlist is represented as a map containing:
  /// - `mixLabel`: The label of the mix (e.g., MIX 1)
  /// - `image`: Path or URL of the playlist image
  /// - `artists`: Associated artist names
  ///
  /// Returns a list of playlist maps.
  Future<List<Map<String, dynamic>>> getMixedPlaylists();

  /// Retrieves station playlists for the "Discover with Stations" section.
  ///
  /// Each station includes:
  /// - `image`: Artwork of the station
  /// - `artists`: Related artists
  ///
  /// Returns a list of station maps.
  Future<List<Map<String, dynamic>>> getStationPlaylists();

  /// Retrieves playlists for the "More of What You Like" section.
  ///
  /// Each item contains:
  /// - `image`: Playlist artwork
  /// - `artists`: Related artist names
  ///
  /// Returns a list of playlist maps.
  Future<List<Map<String, dynamic>>> getMoreOfWhatYouLikePlaylists();
}
