import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';

/// Concrete implementation of [FeedRepository] that delegates data
/// fetching to [FeedDatasource].
///
/// Acts as the bridge between the domain layer and the remote data
/// source, keeping the domain layer decoupled from network concerns.
class FeedRepositoryImpl implements FeedRepository {
  final FeedDatasource _datasource;

  /// Creates a [FeedRepositoryImpl] with the given [FeedDatasource].
  FeedRepositoryImpl(this._datasource);

  /// Fetches the following feed by delegating directly to
  /// [FeedDatasource.getFollowingFeed].
  @override
  Future<List<FeedItemEntity>> getFollowingFeed() =>
      _datasource.getFollowingFeed();

  /// Fetches the discovery feed by delegating to
  /// [FeedDatasource.getDiscoverFeed].
  @override
  Future<List<FeedItemEntity>> getDiscoverFeed() async {
    final items = await _datasource.getDiscoverFeed();
    return items;
  }
}
