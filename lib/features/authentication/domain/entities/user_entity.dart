import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the Rythmify system.
/// This is the core domain entity for a user. It contains the identity
/// information returned after a successful login or registration,
/// extended with profile information to simplify workflow.
/// It extends [Equatable] so two [UserEntity] instances with the same
/// field values are considered equal.
class UserEntity extends Equatable {
  /// The unique identifier of the user, assigned by the backend.
  final String id;

  /// The user's email address, used for login and identification.
  final String email;

  /// The user's display name shown across the app (e.g. in profiles and comments).
  final String displayName;

  /// The user's unique username (e.g. `'karimwi'`).
  final String? username;

  /// The user's avatar URL for their profile picture.
  final String? avatarUrl;

  /// The URL of the user's cover/banner photo.
  final String? coverUrl;

  /// The city component of the user's location (e.g. `'Cairo'`).
  final String? city;

  /// The ISO alpha-2 country code of the user's location (e.g. `'EG'`).
  final String? country;

  /// The user's bio/description text displayed on their profile.
  final String? bio;

  /// The total number of users following this user.
  final int? followersCount;

  /// The total number of users this user is following.
  final int? followingCount;

  /// The total number of tracks this user has uploaded.
  final int? tracksCount;

  /// Whether this user has a verified badge.
  final bool? isVerified;

  /// Whether the user has verified their email address.
  /// Users who have not verified their email may be restricted from
  /// certain features depending on backend policy.
  final bool isEmailVerified;

  /// The JWT access token issued by the backend after authentication.
  /// May be `null` after registration (before the user has logged in),
  /// or when the token has been cleared on sign-out.
  final String? token;

  /// Creates a [UserEntity] with the required identity fields.
  /// [id] and [email] are always required. [token] is optional and
  /// may be `null` immediately after registration.
  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.username,
    this.avatarUrl,
    this.coverUrl,
    this.city,
    this.country,
    this.bio,
    this.followersCount,
    this.followingCount,
    this.tracksCount,
    this.isVerified,
    required this.isEmailVerified,
    this.token,
  });

  /// The list of fields used by [Equatable] to determine equality.
  /// Two [UserEntity] instances are equal if all of these fields match.

  @override
  List<Object?> get props => [
        id,
        email,
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
        isVerified,
        isEmailVerified,
        token,
      ];
}