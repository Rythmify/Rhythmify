import '../entities/feed_item.dart';
import '../repositories/feed_repository.dart';

class GetDiscoverFeedUseCase {
  final FeedRepository _repository;
  GetDiscoverFeedUseCase(this._repository);

  Future<List<FeedItemEntity>> call() => _repository.getDiscoverFeed();
}
