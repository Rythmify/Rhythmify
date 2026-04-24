import '../entities/feed_item.dart';
import '../repositories/feed_repository.dart';

class GetFollowingFeedUseCase {
  final FeedRepository _repository;
  GetFollowingFeedUseCase(this._repository);

  Future<List<FeedItemEntity>> call() => _repository.getFollowingFeed();
}
