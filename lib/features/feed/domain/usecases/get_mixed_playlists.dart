import '../repositories/home_repository.dart';

/// Use case for retrieving "Mixed For You" playlists.
///
/// This class represents a **business operation** responsible for
/// fetching playlists displayed in the "Mixed For You" section on the home screen.
///
/// It follows Clean Architecture principles by:
/// - Depending only on the [HomeRepository] abstraction
/// - Being independent from UI and data source implementations
///
/// This separation ensures better testability and maintainability.

class GetMixedPlaylists {
  /// Repository used to fetch mixed playlists data.
  final HomeRepository repository;

  /// Creates an instance of [GetMixedPlaylists].
  ///
  /// [repository] is injected to allow flexibility and easier testing.

  GetMixedPlaylists(this.repository);

  /// Executes the use case.
  ///
  /// Calls the repository to retrieve a list of mixed playlists.
  ///
  /// Returns a list of maps, where each map contains:
  /// - `image`: The playlist cover (URL or asset path)
  /// - `artists`: The associated artist names
  /// - `mixLabel`: The associated mix label
  Future<List<Map<String, dynamic>>> call() {
    return repository.getMixedPlaylists();
  }
}
