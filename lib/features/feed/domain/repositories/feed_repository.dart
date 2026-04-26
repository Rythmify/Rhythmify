import '../entities/feed_item.dart';

abstract class FeedRepository {
  Future<List<FeedItemEntity>> getFollowingFeed();
  Future<List<FeedItemEntity>> getDiscoverFeed();
}
