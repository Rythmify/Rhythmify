import '../entities/feed_item.dart';

/// Abstract contract for the feed repository in the domain layer.
///
/// Defines the operations available to use cases and other domain
/// consumers, decoupled from any data source implementation.
abstract class FeedRepository {
  /// Returns a list of feed items from users the current user follows.
  Future<List<FeedItemEntity>> getFollowingFeed();

  /// Returns a list of algorithmically recommended feed items
  /// for the current user.
  Future<List<FeedItemEntity>> getDiscoverFeed();
}
