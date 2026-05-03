import '../entities/feed_item.dart';
import '../repositories/feed_repository.dart';

/// Use case for getting following feed
class GetFollowingFeedUseCase {
  final FeedRepository _repository;
  GetFollowingFeedUseCase(this._repository);

  /// Executes the use case, returning a list of following feed tracks
  Future<List<FeedItemEntity>> call() => _repository.getFollowingFeed();
}
