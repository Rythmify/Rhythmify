import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';

/// Use case for retrieving "Hot For You" tracks.
///
/// This class represents a **business operation** responsible for
/// fetching tracks displayed in the "Hot For You" section on the home screen.
///
/// It follows Clean Architecture principles by:
/// - Depending only on the [HomeRepository] abstraction
/// - Being independent from UI and data source implementations
///
/// This separation ensures better testability and maintainability.
class GetHotTracks {
  /// Repository used to fetch hot tracks data.
  final HomeRepository repository;

  /// Creates an instance of [GetHotTracks].
  ///
  /// [repository] is injected to allow flexibility and easier testing.
  GetHotTracks(this.repository);

  /// Executes the use case.
  ///
  /// Calls the repository to retrieve a list of hot tracks.
  ///
  /// Returns a list of [Track] entities representing
  /// popular or personalized tracks.
  Future<List<Track>> call() {
    return repository.getHotTracks();
  }
}
