import '../../domain/entities/profile_entity.dart';

/// Data model for serializing/deserializing profile payloads.
///
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.displayName,
    super.username,
    super.firstName,
    super.lastName,
    super.avatarUrl,
    super.coverUrl,
    super.city,
    super.country,
    super.bio,
    required super.followersCount,
    required super.followingCount,
    required super.tracksCount,
    required super.isFollowing,
    super.isVerified,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? '';
    final displayName = json['display_name'] as String? ?? '';
    final username = json['username'] as String?;
    final firstName = json['first_name'] as String?;
    final lastName = json['last_name'] as String?;
    final avatarUrl =
        json['profile_picture'] as String? ?? json['avatar_url'] as String?;
    final coverUrl =
        json['cover_photo'] as String? ?? json['cover_url'] as String?;
    final city = json['city'] as String?;
    final country = json['country'] as String?;
    final bio = json['bio'] as String?;

    final followersCount = json['followers_count'] as int? ?? 0;
    final followingCount = json['following_count'] as int? ?? 0;
    final tracksCount = json['tracks_count'] as int? ?? 0;
    final isFollowing = json['is_following'] as bool? ?? false;
    final isVerified = json['is_verified'] as bool? ?? false;

    return ProfileModel(
      id: id,
      displayName: displayName,
      username: username,
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      city: city,
      country: country,
      bio: bio,
      followersCount: followersCount,
      followingCount: followingCount,
      tracksCount: tracksCount,
      isFollowing: isFollowing,
      isVerified: isVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture': avatarUrl,
      'cover_photo': coverUrl,
      'city': city,
      'country': country,
      'bio': bio,
      'followers_count': followersCount,
      'following_count': followingCount,
      'tracks_count': tracksCount,
      'is_following': isFollowing,
      'is_verified': isVerified,
    };
  }
}
