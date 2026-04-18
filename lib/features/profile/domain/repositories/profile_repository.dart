import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../entities/profile_user_summary.dart';
import '../../../../core/domain/entities/track.dart';

/// Defines the contract for all profile operations in Rythmify.
///
/// This abstract class sits in the domain layer. Concrete implementations
/// live in the data layer (e.g. [ProfileRepositoryImpl]).
///
/// All methods return [Either]:
/// - [Left] wraps a [Failure] describing what went wrong.
/// - [Right] wraps the successful result.
abstract class ProfileRepository {
  /// Fetches the profile for the given [userId].
  ///
  /// Pass `'me'` as [userId] to fetch the currently authenticated
  /// user's own profile via the `/users/me` endpoint (token-based).
  ///
  /// Returns [Right] with a [ProfileEntity] on success.
  /// Returns [Left] with [ServerFailure] if the profile is not found.
  Future<Either<Failure, ProfileEntity>> getProfile({required String userId});

  /// Updates the authenticated user's profile fields.
  ///
  /// Returns [Right] with the updated [ProfileEntity] on success.
  /// Returns [Left] with [ValidationFailure] if any field is invalid.
  ///
  /// [displayName] — the new display name (max 50 characters).
  /// [username] — the unique username (max 30 characters).
  /// [firstName] — the user's first name.
  /// [lastName] — the user's last name.
  /// [city] — the city portion of the user's location.
  /// [country] — the ISO alpha-2 country code (e.g. `'EG'`).
  /// [bio] — the user's biography text.
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String displayName,
    required String username,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String bio,
  });

  /// Uploads a new avatar image for the authenticated user.
  ///
  /// Sends the file at [filePath] as a multipart POST to `/users/me/avatar`.
  /// Returns [Right] with the updated [ProfileEntity] (including new avatar URL).
  /// Returns [Left] with [ServerFailure] if the file is too large or
  /// an invalid type.
  ///
  /// [filePath] — the absolute path to the image file on device.
  Future<Either<Failure, ProfileEntity>> uploadAvatar({
    required String filePath,
  });

  /// Removes the authenticated user's avatar image.
  ///
  /// Returns [Right] with `void` on success.
  /// Returns [Left] with a [Failure] if the deletion fails.
  Future<Either<Failure, void>> deleteAvatar();

  /// Uploads a new cover/banner photo for the authenticated user.
  ///
  /// Sends the file at [filePath] as a multipart POST to `/users/me/cover`.
  /// Returns [Right] with the updated [ProfileEntity].
  ///
  /// [filePath] — the absolute path to the image file on device.
  Future<Either<Failure, ProfileEntity>> uploadCoverPhoto({
    required String filePath,
  });

  /// Removes the authenticated user's cover photo.
  ///
  /// Returns [Right] with `void` on success.
  /// Returns [Left] with a [Failure] if the deletion fails.
  Future<Either<Failure, void>> deleteCoverPhoto();

  /// Follows the user with the given [userId].
  ///
  /// Returns [Right] with `void` on success.
  /// Returns [Left] with [ServerFailure] containing `'FOLLOW_SELF'`
  /// if the user attempts to follow themselves.
  ///
  /// [userId] — the ID of the user to follow.
  Future<Either<Failure, void>> followUser({required String userId});

  /// Unfollows the user with the given [userId].
  ///
  /// Returns [Right] with `void` on success.
  /// Returns [Left] with a [Failure] if the operation fails.
  ///
  /// [userId] — the ID of the user to unfollow.
  Future<Either<Failure, void>> unfollowUser({required String userId});

  /// Fetches a paginated list of tracks liked by the given user.
  ///
  /// Returns [Right] with a list of [Track] objects.
  /// Returns an empty list when [page] exceeds the total pages.
  ///
  /// [userId] — the ID of the user whose likes to fetch. Pass `'me'`
  /// for the current user.
  /// [page] — the page number (1-based).
  /// [limit] — the number of tracks per page (default 20).
  Future<Either<Failure, List<Track>>> getLikedTracks({
    required String userId,
    required int page,
    required int limit,
  });

  /// Fetches a paginated list of followers for [userId].
  Future<Either<Failure, List<ProfileUserSummary>>> getFollowers({
    required String userId,
    required int page,
    required int limit,
  });

  /// Fetches a paginated list of following users for [userId].
  Future<Either<Failure, List<ProfileUserSummary>>> getFollowing({
    required String userId,
    required int page,
    required int limit,
  });
}
