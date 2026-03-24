import '../repositories/home_repository.dart';

/// Use case for retrieving station playlists.
///
/// This class represents a **single business action**:
/// fetching data for the "Discover with Stations" section.
///
/// It follows Clean Architecture principles by:
/// - Depending only on the [HomeRepository] abstraction
/// - Being independent of UI and data source implementations
///
/// This allows the use case to be easily tested and reused.
class GetStationPlaylists {
  /// Repository used to fetch station playlists.
  final HomeRepository repository;

  /// Creates an instance of [GetStationPlaylists].
  ///
  /// [repository] is injected to allow flexibility and testability.
  GetStationPlaylists(this.repository);

  /// Executes the use case.
  ///
  /// Calls the repository to retrieve station playlists data.
  ///
  /// Returns a list of maps, where each map contains:
  /// - `image`: The station artwork (URL or asset path)
  /// - `artists`: The associated artist names
  Future<List<Map<String, dynamic>>> call() {
    return repository.getStationPlaylists();
  }
}
