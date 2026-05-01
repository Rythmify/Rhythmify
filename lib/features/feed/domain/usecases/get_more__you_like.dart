import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';

/// Use case for getting more of what you like playlists
class GetMoreOfWhatYouLike {
  final HomeRepository repository;
  GetMoreOfWhatYouLike(this.repository);

  /// Executes the use case, returning a list of more of what you like playlists
  Future<List<Track>> call() => repository.getMoreOfWhatYouLike();
}
