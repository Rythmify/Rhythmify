import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/profile_mock_datasource.dart';
import '../../data/datasources/profile_remote_datasource_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_user_connections_usecase.dart';
import '../../../../core/network/api_client.dart';
import 'profile_connections_state.dart';
import 'profile_provider.dart';

/// Riverpod provider for paginated followers/following user lists.
final profileConnectionsProvider =
    NotifierProvider<ProfileConnectionsNotifier, ProfileConnectionsState>(
      ProfileConnectionsNotifier.new,
    );

/// Manages followers/following state transitions and pagination.
class ProfileConnectionsNotifier extends Notifier<ProfileConnectionsState> {
  late final GetUserConnectionsUseCase _getUserConnectionsUseCase;
  int _currentPage = 1;
  String? _loadedUserId;
  ProfileConnectionsType? _loadedType;

  @override
  ProfileConnectionsState build() {
    final datasource = useProfileMockData
        ? ProfileMockDatasource()
        : ProfileRemoteDatasourceImpl(client: apiClient);
    final repository = ProfileRepositoryImpl(remoteDatasource: datasource);
    _getUserConnectionsUseCase = GetUserConnectionsUseCase(repository);
    return const ProfileConnectionsInitial();
  }

  /// Loads the first page or additional pages based on [refresh].
  ///
  /// Automatically treats the request as a refresh when [userId] or [type]
  /// differs from the last loaded set — this prevents list accumulation when
  /// the same provider instance is reused for a different profile or tab.
  Future<void> loadConnections({
    required String userId,
    required ProfileConnectionsType type,
    bool refresh = false,
  }) async {
    final contextChanged = userId != _loadedUserId || type != _loadedType;

    final shouldRefresh = refresh || contextChanged;

    final currentState = state;

    if (shouldRefresh ||
        currentState is! ProfileConnectionsLoaded ||
        currentState.users.isEmpty) {
      _currentPage = 1;
      _loadedUserId = userId;
      _loadedType = type;

      state = const ProfileConnectionsLoading();

      final result = await _getUserConnectionsUseCase(
        userId: userId,
        page: _currentPage,
        limit: 20,
        type: type,
      );
      if (result.isLeft()) {
        state = ProfileConnectionsError(
          result.fold((failure) => failure.message, (_) => 'Unknown error'),
        );
        return;
      }

      final users = result.getOrElse(() => const []);
      final totalCount = await _fetchConnectionsTotalCount(
        userId: userId,
        type: type,
      );
      _currentPage++;
      state = ProfileConnectionsLoaded(
        users: users,
        isLoadingMore: false,
        hasMore: users.length == 20,
        totalCount: totalCount,
      );
      return;
    }

    if (currentState.isLoadingMore || !currentState.hasMore) return;

    state = currentState.copyWith(isLoadingMore: true);

    final result = await _getUserConnectionsUseCase(
      userId: userId,
      page: _currentPage,
      limit: 20,
      type: type,
    );

    if (result.isLeft()) {
      state = currentState.copyWith(isLoadingMore: false);
      return;
    }

    final users = result.getOrElse(() => const []);
    _currentPage++;
    state = currentState.copyWith(
      users: [...currentState.users, ...users],
      isLoadingMore: false,
      hasMore: users.length == 20,
    );
  }

  Future<int> _fetchConnectionsTotalCount({
    required String userId,
    required ProfileConnectionsType type,
  }) async {
    try {
      final endpoint = type == ProfileConnectionsType.followers
          ? '/users/$userId/followers'
          : '/users/$userId/following';
      final response = await apiClient.dio.get(
        endpoint,
        queryParameters: {'page': 1, 'limit': 1},
      );
      return _extractTotalCount(response.data);
    } on DioException {
      return 0;
    } catch (_) {
      return 0;
    }
  }

  int _extractTotalCount(dynamic rawResponse) {
    if (rawResponse is! Map<String, dynamic>) return 0;

    final data = rawResponse['data'];
    if (data is! Map<String, dynamic>) return 0;
    final meta = data['meta'];
    if (meta is! Map<String, dynamic>) return 0;
    final total = meta['total'];
    if (total is int) return total;
    if (total is num) return total.toInt();
    if (total is String) return int.tryParse(total) ?? 0;
    return 0;
  }
}
