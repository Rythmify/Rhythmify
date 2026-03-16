import '../repositories/home_repository.dart';

class GetMixedPlaylists {
  final HomeRepository repository;

  GetMixedPlaylists(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getMixedPlaylists();
  }
}
