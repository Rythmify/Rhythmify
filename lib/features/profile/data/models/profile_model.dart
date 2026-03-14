import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.displayName,
    super.avatarUrl,
    super.coverUrl,
    super.city,
    super.country,
    super.bio,
    required super.followersCount,
    required super.followingCount,
    required super.tracksCount,
    required super.isFollowing,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      displayName: json['display_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      bio: json['bio'] as String?,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      tracksCount: json['tracks_count'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'city': city,
      'country': country,
      'bio': bio,
      'followers_count': followersCount,
      'following_count': followingCount,
      'tracks_count': tracksCount,
      'is_following': isFollowing,
    };
  }
}