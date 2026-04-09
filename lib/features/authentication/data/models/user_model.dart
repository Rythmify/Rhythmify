import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.username,
    super.avatarUrl,
    super.coverUrl,
    super.city,
    super.country,
    super.bio,
    super.followersCount,
    super.followingCount,
    super.tracksCount,
    super.isVerified,
    required super.isEmailVerified,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawAvatarUrl =
        json['avatar_url'] as String? ?? json['profile_picture'] as String?;
    final rawCoverUrl =
        json['cover_url'] as String? ?? json['cover_photo'] as String?;

    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? '',
      username: json['username'] as String?,
      avatarUrl: rawAvatarUrl?.trim().isEmpty == true
          ? null
          : rawAvatarUrl?.trim(),
      coverUrl: rawCoverUrl?.trim().isEmpty == true
          ? null
          : rawCoverUrl?.trim(),
      city: json['city'] as String?,
      country: json['country'] as String?,
      bio: json['bio'] as String?,
      followersCount: json['followers_count'] as int?,
      followingCount: json['following_count'] as int?,
      tracksCount: json['tracks_count'] as int?,
      isVerified: json['is_verified'] as bool?,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'username': username,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'city': city,
      'country': country,
      'bio': bio,
      'followers_count': followersCount,
      'following_count': followingCount,
      'tracks_count': tracksCount,
      'is_verified': isVerified,
      'is_email_verified': isEmailVerified,
      'token': token,
    };
  }

  factory UserModel.fromSupabase(Map<String, dynamic> data, {String? token}) {
    final rawAvatarUrl =
        data['avatar_url'] as String? ?? data['profile_picture'] as String?;
    final rawCoverUrl =
        data['cover_url'] as String? ?? data['cover_photo'] as String?;

    return UserModel(
      id: data['id'] as String,
      email: data['email'] as String,
      displayName: data['display_name'] as String? ?? '',
      username: data['username'] as String?,
      avatarUrl: rawAvatarUrl?.trim().isEmpty == true
          ? null
          : rawAvatarUrl?.trim(),
      coverUrl: rawCoverUrl?.trim().isEmpty == true
          ? null
          : rawCoverUrl?.trim(),
      city: data['city'] as String?,
      country: data['country'] as String?,
      bio: data['bio'] as String?,
      followersCount: data['followers_count'] as int?,
      followingCount: data['following_count'] as int?,
      tracksCount: data['tracks_count'] as int?,
      isVerified: data['is_verified'] as bool?,
      isEmailVerified: data['email_confirmed_at'] != null,
      token: token,
    );
  }
}
