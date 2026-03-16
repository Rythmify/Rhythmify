import '../repositories/home_repository.dart';

class GetMoreOfWhatYouLike {
  final HomeRepository repository;

  GetMoreOfWhatYouLike(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getMoreOfWhatYouLikePlaylists();
  }
}
