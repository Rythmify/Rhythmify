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

final _feedRepositoryProvider = Provider((ref) {
  return FeedRepositoryImpl(FeedRemoteDatasourceImpl(client: apiClient));
});

final followingFeedProvider = FutureProvider<List<FeedItemEntity>>((ref) {
  final usecase = GetFollowingFeedUseCase(ref.read(_feedRepositoryProvider));
  return usecase();
});

final discoverFeedProvider = FutureProvider<List<FeedItemEntity>>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState is! AuthAuthenticated) return [];

  final usecase = GetDiscoverFeedUseCase(ref.read(_feedRepositoryProvider));
  return usecase();
});

final playerSheetNotifier = ValueNotifier<VoidCallback?>(null);
