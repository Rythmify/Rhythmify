import 'package:equatable/equatable.dart';

/// Represents a user's public profile in the Rythmify system.
class ProfileEntity extends Equatable {
  final String id;
  final String displayName;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? coverUrl;
  final String? city;
  final String? country;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int tracksCount;
  final bool isFollowing;
  final bool isVerified;

  const ProfileEntity({
    required this.id,
    required this.displayName,
    this.username,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.coverUrl,
    this.city,
    this.country,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
    this.tracksCount = 0,
    this.isFollowing = false,
    this.isVerified = false,
  });

  ProfileEntity copyWith({
    String? id,
    String? displayName,
    String? username,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? coverUrl,
    String? city,
    String? country,
    String? bio,
    int? followersCount,
    int? followingCount,
    int? tracksCount,
    bool? isFollowing,
    bool? isVerified,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      city: city ?? this.city,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      tracksCount: tracksCount ?? this.tracksCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  ProfileEntity copyWithFollowing({
    required bool isFollowing,
    required int followersCount,
  }) {
    return copyWith(
      isFollowing: isFollowing,
      followersCount: followersCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        username,
        firstName,
        lastName,
        avatarUrl,
        coverUrl,
        city,
        country,
        bio,
        followersCount,
        followingCount,
        tracksCount,
        isFollowing,
        isVerified,
      ];
}
