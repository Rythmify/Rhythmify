import '../../domain/entities/profile_user_summary.dart';

/// Data model for users returned by followers/following profile endpoints.
class ProfileUserSummaryModel extends ProfileUserSummary {
  /// Creates a [ProfileUserSummaryModel].
  const ProfileUserSummaryModel({
    required super.id,
    required super.displayName,
    required super.username,
    super.avatarUrl,
  });

  /// Builds a model from backend JSON payload.
  factory ProfileUserSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserSummaryModel(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      displayName:
          json['display_name'] as String? ??
          json['name'] as String? ??
          json['username'] as String? ??
          '',
      username: json['username'] as String? ?? '',
      avatarUrl:
          json['profile_picture'] as String? ??
          json['avatar_url'] as String? ??
          json['avatar'] as String?,
    );
  }
}
