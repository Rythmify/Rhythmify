import '../repositories/home_repository.dart';
import '../entities/discover_station.dart';

class GetDiscoverStations {
  final HomeRepository repository;
  GetDiscoverStations(this.repository);

  Future<List<DiscoverStation>> call() => repository.getDiscoverStations();
}
