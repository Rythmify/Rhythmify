import '../entities/feed_item.dart';
import '../repositories/feed_repository.dart';

/// Use case for getting discover feed
class GetDiscoverFeedUseCase {
  final FeedRepository _repository;
  GetDiscoverFeedUseCase(this._repository);

  /// Executes the use case, returning a list of discover tracks
  Future<List<FeedItemEntity>> call() => _repository.getDiscoverFeed();
}
