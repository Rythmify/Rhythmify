import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String? coverUrl;
  final String? city;
  final String? country;
  final String? bio;
  final int followersCount;
  final int followingCount;
  final int tracksCount;
  final bool isFollowing;

  const ProfileEntity({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.coverUrl,
    this.city,
    this.country,
    this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.tracksCount,
    required this.isFollowing,
  });

  ProfileEntity copyWithFollowing({
    required bool isFollowing,
    required int followersCount,
  }) {
    return ProfileEntity(
      id: id,
      displayName: displayName,
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      city: city,
      country: country,
      bio: bio,
      followersCount: followersCount,
      followingCount: followingCount,
      tracksCount: tracksCount,
      isFollowing: isFollowing,
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        avatarUrl,
        coverUrl,
        city,
        country,
        bio,
        followersCount,
        followingCount,
        tracksCount,
        isFollowing,
      ];
}