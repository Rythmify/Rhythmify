import '../../domain/entities/follow_status.dart';

/// JSON model for the `GET /users/{user_id}/follow-status` response.
///
/// Maps the `data` object from the API into a [FollowStatus] domain entity.
class FollowStatusModel extends FollowStatus {
  /// Creates a [FollowStatusModel] from parsed field values.
  const FollowStatusModel({
    required super.isFollowing,
    required super.isFollowedBy,
    required super.isBlocking,
    required super.isBlockedBy,
  });

  /// Parses a [FollowStatusModel] from the `data` map inside the API response.
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "data": {
  ///     "is_following": true,
  ///     "is_followed_by": false,
  ///     "is_blocking": false,
  ///     "is_blocked_by": false
  ///   }
  /// }
  /// ```
  factory FollowStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return FollowStatusModel(
      isFollowing: data['is_following'] as bool? ?? false,
      isFollowedBy: data['is_followed_by'] as bool? ?? false,
      isBlocking: data['is_blocking'] as bool? ?? false,
      isBlockedBy: data['is_blocked_by'] as bool? ?? false,
    );
  }
}
