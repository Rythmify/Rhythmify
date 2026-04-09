import 'package:equatable/equatable.dart';

/// Represents a user's public profile in the Rythmify system.
///
/// This is the core domain entity for profile data. It contains all
/// information displayed on a user's profile page, including their
/// avatar, bio, location, and social statistics.
///
/// Extends [Equatable] so two [ProfileEntity] instances with the same
/// field values are considered equal — useful for state change detection
/// in Riverpod providers.
class ProfileEntity extends Equatable {
  /// The unique identifier of the user this profile belongs to.
  final String id;

  /// The user's public display name shown across the app.
  final String displayName;

  /// The user's unique username (e.g. `'karimwi'`).
  ///
  /// May be `null` if the user has not set one.
  final String? username;

  /// The URL of the user's avatar/profile picture.
  ///
  /// May be `null` if the user has not uploaded a photo.
  /// Maps to the `profile_picture` field from the API response.
  final String? avatarUrl;

  /// The URL of the user's cover/banner photo.
  ///
  /// May be `null` if the user has not uploaded a cover photo.
  /// Maps to the `cover_photo` field from the API response.
  final String? coverUrl;

  /// The city component of the user's location (e.g. `'Cairo'`).
  ///
  /// Stored separately from [country] to match the API spec.
  /// May be `null` if the user has not set a location.
  final String? city;

  /// The ISO alpha-2 country code of the user's location (e.g. `'EG'`).
  ///
  /// Stored as an ISO code internally even though the UI displays
  /// the full country name. May be `null` if not set.
  final String? country;

  /// The user's bio/description text displayed on their profile.
  ///
  /// May be `null` if the user has not written a bio.
  final String? bio;

  /// The total number of users following this profile.
  final int followersCount;

  /// The total number of users this profile is following.
  final int followingCount;

  /// The total number of tracks this user has uploaded.
  final int tracksCount;

  /// Whether the currently authenticated user follows this profile.
  ///
  /// Used to drive the Follow/Following button state in [PublicProfilePage].
  final bool isFollowing;

  /// Whether this profile has a verified badge.
  ///
  /// Defaults to `false` when not provided by the API.
  final bool isVerified;

  /// The timestamp when this profile was last updated.
  ///
  /// Used for cache-busting profile pictures when the same URL is reused.
  /// This ensures the UI re-fetches the avatar after upload/deletion.
  final DateTime? updatedAt;

  /// Creates a [ProfileEntity] with all required fields.
  ///
  /// Optional fields ([username], [avatarUrl], [coverUrl], [city],
  /// [country], [bio], [updatedAt]) default to `null`. [isVerified] defaults to `false`.
  const ProfileEntity({
    required this.id,
    required this.displayName,
    this.username,
    this.avatarUrl,
    this.coverUrl,
    this.city,
    this.country,
    this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.tracksCount,
    required this.isFollowing,
    this.isVerified = false,
    this.updatedAt,
  });

  /// Returns a copy of this profile with updated [isFollowing] and
  /// [followersCount] values.
  ///
  /// Used for optimistic follow/unfollow updates in [ProfileNotifier]
  /// before the backend response is received.
  ///
  /// [isFollowing] — the new follow state.
  /// [followersCount] — the adjusted follower count (incremented on
  /// follow, decremented on unfollow).
  ProfileEntity copyWithFollowing({
    required bool isFollowing,
    required int followersCount,
  }) {
    return ProfileEntity(
      id: id,
      displayName: displayName,
      username: username,
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
      updatedAt: updatedAt,
    );
  }

  /// The list of fields used by [Equatable] to determine equality.
  @override
  List<Object?> get props => [
    id,
    displayName,
    username,
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
    updatedAt,
  ];
}
