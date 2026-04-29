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
    super.instagramUrl,
    super.facebookUrl,
    super.githubUrl,
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
    final instagramUrl =
        json['instagram_url'] as String? ?? json['instagramUrl'] as String?;
    final facebookUrl =
        json['facebook_url'] as String? ?? json['facebookUrl'] as String?;
    final githubUrl =
        json['github_url'] as String? ?? json['githubUrl'] as String?;

    final followersCount = _readCount(
      json,
      primaryKey: 'followers_count',
      fallbackKey: 'follower_count',
      secondaryFallbackKey: 'followersCount',
    );
    final followingCount = _readCount(
      json,
      primaryKey: 'following_count',
      fallbackKey: 'following_count_total',
      secondaryFallbackKey: 'followingCount',
    );
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
      instagramUrl: instagramUrl,
      facebookUrl: facebookUrl,
      githubUrl: githubUrl,
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
      'instagram_url': instagramUrl,
      'facebook_url': facebookUrl,
      'github_url': githubUrl,
      'followers_count': followersCount,
      'following_count': followingCount,
      'tracks_count': tracksCount,
      'is_following': isFollowing,
      'is_verified': isVerified,
    };
  }

  /// Parses a count field from API JSON without accumulating values.
  ///
  /// This intentionally reads a single canonical field (with a single fallback)
  /// and never combines multiple sources, preventing accidental double-counting.
  static int _readCount(
    Map<String, dynamic> json, {
    required String primaryKey,
    String? fallbackKey,
    String? secondaryFallbackKey,
  }) {
    int parse(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is List) return value.length;
      return 0;
    }

    if (json.containsKey(primaryKey)) {
      return parse(json[primaryKey]);
    }
    if (fallbackKey != null && json.containsKey(fallbackKey)) {
      return parse(json[fallbackKey]);
    }
    if (secondaryFallbackKey != null &&
        json.containsKey(secondaryFallbackKey)) {
      return parse(json[secondaryFallbackKey]);
    }
    return 0;
  }
}
