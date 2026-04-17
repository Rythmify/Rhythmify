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

  /// Creates a [ProfileUserSummary].
  const ProfileUserSummary({
    required this.id,
    required this.displayName,
    required this.username,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, displayName, username, avatarUrl];
}
