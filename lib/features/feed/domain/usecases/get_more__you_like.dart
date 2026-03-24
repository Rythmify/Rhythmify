import '../repositories/home_repository.dart';

/// Use case for retrieving "More of what you like" playlists.
///
/// This class represents a **business operation** responsible for
/// fetching playlists displayed in the "More Of What You Like" section on the home screen.
///
/// It follows Clean Architecture principles by:
/// - Depending only on the [HomeRepository] abstraction
/// - Being independent from UI and data source implementations
///
/// This separation ensures better testability and maintainability.
class GetMoreOfWhatYouLike {
  /// Repository used to fetch more of what you like playlists data.
  final HomeRepository repository;

  /// Creates an instance of [GetMoreOfWhatYouLike].
  ///
  /// [repository] is injected to allow flexibility and easier testing.

  GetMoreOfWhatYouLike(this.repository);

  /// Executes the use case.
  ///
  /// Calls the repository to retrieve a list of more of what you like playlists.
  ///
  /// Returns a list of maps, where each map contains:
  /// - `image`: The playlist cover (URL or asset path)
  /// - `artists`: The associated artist names

  Future<List<Map<String, dynamic>>> call() {
    return repository.getMoreOfWhatYouLikePlaylists();
  }
}
