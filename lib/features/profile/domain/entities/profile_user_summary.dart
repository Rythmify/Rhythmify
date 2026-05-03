import 'package:equatable/equatable.dart';

/// Lightweight user entity used in profile followers/following lists.
class ProfileUserSummary extends Equatable {
  /// User identifier.
  final String id;

  /// Public display name.
  final String displayName;

  /// Public username.
  final String username;

  /// Avatar image URL.
  final String? avatarUrl;

  /// Whether the authenticated user is currently following this user.
  ///
  /// Populated directly from the followers/following list endpoint so the
  /// [FollowButton] can show the correct initial state without needing to
  /// load a full profile for every row.
  final bool isFollowing;

  /// Creates a [ProfileUserSummary].
  const ProfileUserSummary({
    required this.id,
    required this.displayName,
    required this.username,
    this.avatarUrl,
    this.isFollowing = false,
  });

  @override
  List<Object?> get props => [
    id,
    displayName,
    username,
    avatarUrl,
    isFollowing,
  ];
}
