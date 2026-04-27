/// Represents the bidirectional relationship between the authenticated user
/// and a target user, including both follow and block states.
class FollowStatus {
  /// Whether the authenticated user follows the target user.
  final bool isFollowing;

  /// Whether the target user follows the authenticated user.
  final bool isFollowedBy;

  /// Whether the authenticated user has blocked the target user.
  ///
  /// When `true`, the profile page should render a blocked screen
  /// instead of any profile information.
  final bool isBlocking;

  /// Whether the target user has blocked the authenticated user.
  ///
  /// When `true`, the profile may be inaccessible even if not explicitly blocked.
  final bool isBlockedBy;

  /// Creates a [FollowStatus] with all four relationship flags.
  const FollowStatus({
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isBlocking,
    required this.isBlockedBy,
  });

  /// Creates a copy of this [FollowStatus] with the given fields replaced.
  FollowStatus copyWith({
    bool? isFollowing,
    bool? isFollowedBy,
    bool? isBlocking,
    bool? isBlockedBy,
  }) {
    return FollowStatus(
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      isBlocking: isBlocking ?? this.isBlocking,
      isBlockedBy: isBlockedBy ?? this.isBlockedBy,
    );
  }

  /// A neutral status with no relationship in either direction.
  ///
  /// Used as a safe default before the real status has been loaded.
  static const empty = FollowStatus(
    isFollowing: false,
    isFollowedBy: false,
    isBlocking: false,
    isBlockedBy: false,
  );
}
