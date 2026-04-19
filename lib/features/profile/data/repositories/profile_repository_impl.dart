import 'package:dartz/dartz.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/profile_user_summary.dart';
import '../../../../core/domain/entities/track.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/profile_remote_datasource.dart';

/// Profile repository that converts datasource exceptions into domain failures.

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource remoteDatasource;

  ProfileRepositoryImpl({required this.remoteDatasource});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile({
    required String userId,
  }) async {
    try {
      final profile = await remoteDatasource.getProfile(userId: userId);
      return Right(profile);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String displayName,
    required String username,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String bio,
  }) async {
    try {
      final profile = await remoteDatasource.updateProfile(
        displayName: displayName,
        username: username,
        firstName: firstName,
        lastName: lastName,
        city: city,
        country: country,
        bio: bio,
      );
      return Right(profile);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> uploadAvatar({
    required String filePath,
  }) async {
    try {
      final profile = await remoteDatasource.uploadAvatar(filePath: filePath);
      return Right(profile);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAvatar() async {
    try {
      await remoteDatasource.deleteAvatar();
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> uploadCoverPhoto({
    required String filePath,
  }) async {
    try {
      final profile = await remoteDatasource.uploadCoverPhoto(
        filePath: filePath,
      );
      return Right(profile);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCoverPhoto() async {
    try {
      await remoteDatasource.deleteCoverPhoto();
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> followUser({required String userId}) async {
    try {
      await remoteDatasource.followUser(userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unfollowUser({required String userId}) async {
    try {
      await remoteDatasource.unfollowUser(userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Track>>> getLikedTracks({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final result = await remoteDatasource.getLikedTracks(
        userId: userId,
        page: page,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Track>>> getUploadedTracks({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final result = await remoteDatasource.getUploadedTracks(
        userId: userId,
        page: page,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Track>>> getRepostedTracks({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final result = await remoteDatasource.getRepostedTracks(
        userId: userId,
        page: page,
        limit: limit,
      );
      return Right(result);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProfileUserSummary>>> getFollowers({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final users = await remoteDatasource.getFollowers(
        userId: userId,
        page: page,
        limit: limit,
      );
      return Right(users);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProfileUserSummary>>> getFollowing({
    required String userId,
    required int page,
    required int limit,
  }) async {
    try {
      final users = await remoteDatasource.getFollowing(
        userId: userId,
        page: page,
        limit: limit,
      );
      return Right(users);
    } catch (e) {
      return Left(_mapError(e.toString()));
    }
  }

  // ── Error mapping ─────────────────────────────────────────────────────
  Failure _mapError(String error) {
    if (error.contains('PROFILE_NOT_FOUND')) {
      return const ServerFailure('User profile not found.');
    } else if (error.contains('UPLOAD_FILE_TOO_LARGE')) {
      return const ServerFailure('File is too large. Maximum size is 5MB.');
    } else if (error.contains('UPLOAD_INVALID_FILE_TYPE')) {
      return const ServerFailure('Invalid file type. Use JPG, PNG, or WEBP.');
    } else if (error.contains('FOLLOW_SELF')) {
      return const ServerFailure('You cannot follow yourself.');
    } else if (error.contains('PERMISSION_DENIED')) {
      return const ServerFailure('You do not have permission to do this.');
    } else if (error.contains('VALIDATION_FAILED')) {
      return const ServerFailure('Please check your inputs and try again.');
    } else if (error.contains('RATE_LIMIT_EXCEEDED')) {
      return const TooManyRequestsFailure();
    } else if (error.contains('network') || error.contains('socket')) {
      return const NetworkFailure();
    }
    return ServerFailure(error);
  }
}
