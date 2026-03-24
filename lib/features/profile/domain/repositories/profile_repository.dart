import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../../../../core/domain/entities/track.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile({required String userId});

  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String displayName,
    required String city,
    required String country,
    required String bio,
  });

  Future<Either<Failure, ProfileEntity>> uploadAvatar({
    required String filePath,
  });

  Future<Either<Failure, void>> deleteAvatar();

  Future<Either<Failure, ProfileEntity>> uploadCoverPhoto({
    required String filePath,
  });

  Future<Either<Failure, void>> deleteCoverPhoto();

  Future<Either<Failure, void>> followUser({required String userId});

  Future<Either<Failure, void>> unfollowUser({required String userId});

  Future<Either<Failure, List<Track>>> getLikedTracks({
    required String userId,
    required int page,
    required int limit,
  });
}
