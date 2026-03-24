import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';

/// Use case for retrieving trending tracks by genre.
///
/// This class represents a **business operation** responsible for
/// fetching tracks displayed in the "Trending by Genre" section.
///
/// It follows Clean Architecture principles by:
/// - Depending only on the [HomeRepository] abstraction
/// - Remaining independent from UI and data source implementations
///
/// This makes the use case reusable and easy to test.
class GetTrendingTracks {
  /// Repository used to fetch trending tracks data.
  final HomeRepository repository;

  /// Creates an instance of [GetTrendingTracks].
  ///
  /// [repository] is injected to support dependency inversion
  /// and improve testability.
  GetTrendingTracks(this.repository);

  /// Executes the use case.
  ///
  /// [genre] specifies the category of tracks to retrieve.
  ///
  /// Calls the repository to fetch trending tracks filtered by genre.
  ///
  /// Returns a list of [Track] entities.
  Future<List<Track>> call(String genre) {
    return repository.getTrendingTracks(genre);
  }
}
