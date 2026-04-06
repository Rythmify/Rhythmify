import '../repositories/home_repository.dart';
import '../../../../core/domain/entities/track.dart';

class GetMoreOfWhatYouLike {
  final HomeRepository repository;
  GetMoreOfWhatYouLike(this.repository);

  Future<List<Track>> call() => repository.getMoreOfWhatYouLike();
}
