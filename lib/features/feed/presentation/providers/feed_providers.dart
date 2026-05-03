// coverage:ignore-file
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/feed_remote_datasource.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/entities/feed_item.dart';
import '../../domain/usecases/get_following_feed_usecase.dart';
import '../../domain/usecases/get_discover_feed_usecase.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../authentication/presentation/providers/auth_state.dart';

/// Internal provider that constructs and exposes the [FeedRepositoryImpl].
///
/// Not exposed publicly — consumed only by feed use case providers.
final _feedRepositoryProvider = Provider((ref) {
  return FeedRepositoryImpl(FeedRemoteDatasourceImpl(client: apiClient));
});

/// Provides the list of feed items from users the current user follows.
///
/// Executes [GetFollowingFeedUseCase] on every watch.
final followingFeedProvider = FutureProvider<List<FeedItemEntity>>((ref) {
  final usecase = GetFollowingFeedUseCase(ref.read(_feedRepositoryProvider));
  return usecase();
});

/// Provides the algorithmically recommended discovery feed.
///
/// Returns an empty list if the user is not authenticated.
/// Executes [GetDiscoverFeedUseCase] on every watch.
final discoverFeedProvider = FutureProvider<List<FeedItemEntity>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState is! AuthAuthenticated) return [];

  final usecase = GetDiscoverFeedUseCase(ref.read(_feedRepositoryProvider));
  return usecase();
});

/// Global notifier used to register a callback that expands the player sheet.
///
/// Widgets that own the sheet assign their expand callback here so that
/// other parts of the UI can trigger it without direct widget references.
final playerSheetNotifier = ValueNotifier<VoidCallback?>(null);

/// Global notifier used to register a callback that collapses the player sheet.
///
/// Mirrors [playerSheetNotifier] for the collapse direction.
final playerCollapseNotifier = ValueNotifier<VoidCallback?>(null);
