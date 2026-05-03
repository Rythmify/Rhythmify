import '../../domain/entities/profile_user_summary.dart';

/// Base state for followers/following screens.
sealed class ProfileConnectionsState {
  /// Creates a [ProfileConnectionsState].
  const ProfileConnectionsState();
}

/// Initial state before loading starts.
class ProfileConnectionsInitial extends ProfileConnectionsState {
  /// Creates [ProfileConnectionsInitial].
  const ProfileConnectionsInitial();
}

/// Loading state for first page.
class ProfileConnectionsLoading extends ProfileConnectionsState {
  /// Creates [ProfileConnectionsLoading].
  const ProfileConnectionsLoading();
}

/// Error state with message.
class ProfileConnectionsError extends ProfileConnectionsState {
  /// Error message to render.
  final String message;

  /// Creates [ProfileConnectionsError].
  const ProfileConnectionsError(this.message);
}

/// Loaded state with items and pagination flags.
class ProfileConnectionsLoaded extends ProfileConnectionsState {
  /// Current user items.
  final List<ProfileUserSummary> users;

  /// Indicates if next page is currently loading.
  final bool isLoadingMore;

  /// Indicates if there are more pages to fetch.
  final bool hasMore;

  /// Total available items from backend pagination metadata.
  final int totalCount;

  /// Creates [ProfileConnectionsLoaded].
  const ProfileConnectionsLoaded({
    required this.users,
    required this.isLoadingMore,
    required this.hasMore,
    required this.totalCount,
  });

  /// Creates an updated copy of the current state.
  ProfileConnectionsLoaded copyWith({
    List<ProfileUserSummary>? users,
    bool? isLoadingMore,
    bool? hasMore,
    int? totalCount,
  }) {
    return ProfileConnectionsLoaded(
      users: users ?? this.users,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
