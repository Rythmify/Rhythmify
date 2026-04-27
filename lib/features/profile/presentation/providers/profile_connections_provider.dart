import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/models/profile_user_summary_model.dart';
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
      final totalCount =
          await _fetchConnectionsTotalCount(userId: userId, type: type) ??
          users.length;
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

  Future<int?> _fetchConnectionsTotalCount({
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
      return null;
    } catch (_) {
      return null;
    }
  }

  int? _extractTotalCount(dynamic rawResponse) {
    if (rawResponse is! Map<String, dynamic>) return null;

    final data = rawResponse['data'];
    if (data is Map<String, dynamic>) {
      final pagination = data['pagination'];
      final meta = data['meta'];
      final totals = <dynamic>[
        data['total'],
        data['count'],
        data['total_count'],
        pagination is Map<String, dynamic> ? pagination['total'] : null,
        meta is Map<String, dynamic> ? meta['total'] : null,
      ];
      for (final value in totals) {
        final parsed = _parseInt(value);
        if (parsed != null) return parsed;
      }
      final users = data['users'];
      if (users is List) return users.length;
      final followers = data['followers'];
      if (followers is List) return followers.length;
      final following = data['following'];
      if (following is List) return following.length;
    }

    final topLevelTotals = <dynamic>[
      rawResponse['total'],
      rawResponse['count'],
      rawResponse['total_count'],
    ];
    for (final value in topLevelTotals) {
      final parsed = _parseInt(value);
      if (parsed != null) return parsed;
    }

    final parsedUsers = _extractUsers(rawResponse);
    return parsedUsers.isNotEmpty ? parsedUsers.length : null;
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<ProfileUserSummaryModel> _extractUsers(dynamic rawResponse) {
    if (rawResponse is! Map<String, dynamic>) return const [];
    final data = rawResponse['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (e) =>
                ProfileUserSummaryModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    }
    if (data is Map<String, dynamic>) {
      final candidates = <dynamic>[
        data['items'],
        data['results'],
        data['users'],
        data['followers'],
        data['following'],
        data['data'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate
              .whereType<Map>()
              .map(
                (e) => ProfileUserSummaryModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();
        }
      }
    }
    return const [];
  }
}
