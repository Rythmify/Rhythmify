import '../repositories/home_repository.dart';
import '../entities/discover_station.dart';

/// Use case for getting stations
class GetDiscoverStations {
  final HomeRepository repository;
  GetDiscoverStations(this.repository);

  /// Executes the use case, returning a list of stations
  Future<List<DiscoverStation>> call() => repository.getDiscoverStations();
}
