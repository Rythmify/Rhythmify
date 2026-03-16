import '../repositories/home_repository.dart';

class GetStationPlaylists {
  final HomeRepository repository;

  GetStationPlaylists(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getStationPlaylists();
  }
}
