import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedDatasource _datasource;

  FeedRepositoryImpl(this._datasource);

  @override
  Future<List<FeedItemEntity>> getFollowingFeed() =>
      _datasource.getFollowingFeed();

  @override
  Future<List<FeedItemEntity>> getDiscoverFeed() =>
      _datasource.getDiscoverFeed();
}
