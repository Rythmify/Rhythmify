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
  final String? instagramUrl;
  final String? facebookUrl;
  final String? githubUrl;
  final int followersCount;
  final int followingCount;
  final int tracksCount;
  final bool isFollowing;
  final bool isVerified;
  final bool isUserPremium;

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
    this.instagramUrl,
    this.facebookUrl,
    this.githubUrl,
    this.followersCount = 0,
    this.followingCount = 0,
    this.tracksCount = 0,
    this.isFollowing = false,
    this.isVerified = false,
    this.isUserPremium = false,
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
    String? instagramUrl,
    String? facebookUrl,
    String? githubUrl,
    int? followersCount,
    int? followingCount,
    int? tracksCount,
    bool? isFollowing,
    bool? isVerified,
    bool? isUserPremium,
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
      instagramUrl: instagramUrl ?? this.instagramUrl,
      facebookUrl: facebookUrl ?? this.facebookUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      tracksCount: tracksCount ?? this.tracksCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isVerified: isVerified ?? this.isVerified,
      isUserPremium: isUserPremium ?? this.isUserPremium,
    );
  }

  ProfileEntity copyWithFollowing({
    required bool isFollowing,
    required int followersCount,
  }) {
    return copyWith(isFollowing: isFollowing, followersCount: followersCount);
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
    instagramUrl,
    facebookUrl,
    githubUrl,
    followersCount,
    followingCount,
    tracksCount,
    isFollowing,
    isVerified,
    isUserPremium,
  ];
}
