import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Use case that uploads an avatar image for the authenticated user.
///
/// Delegates to [ProfileRepository.uploadAvatar].
class UploadAvatarUseCase {
  /// The repository used to upload the avatar.
  final ProfileRepository repository;

  /// Creates an [UploadAvatarUseCase] with the given [repository].
  UploadAvatarUseCase(this.repository);

  /// Uploads the image at [filePath] as the user's avatar.
  ///
  /// Returns [Right] with updated [ProfileEntity], or [Left] with a [Failure].
  Future<Either<Failure, ProfileEntity>> call({
    required String userId,
    required String filePath,
  }) {
    return repository.uploadAvatar(userId: userId, filePath: filePath);
  }
}
