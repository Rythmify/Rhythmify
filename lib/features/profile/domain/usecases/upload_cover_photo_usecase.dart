import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Use case that uploads a cover photo for the authenticated user.
///
/// Delegates to [ProfileRepository.uploadCoverPhoto].
class UploadCoverPhotoUseCase {
  /// The repository used to upload the cover photo.
  final ProfileRepository repository;

  /// Creates an [UploadCoverPhotoUseCase] with the given [repository].
  UploadCoverPhotoUseCase(this.repository);

  /// Uploads the image at [filePath] as the user's cover photo.
  ///
  /// Returns [Right] with updated [ProfileEntity], or [Left] with a [Failure].
  Future<Either<Failure, ProfileEntity>> call({required String filePath}) {
    return repository.uploadCoverPhoto(filePath: filePath);
  }
}
