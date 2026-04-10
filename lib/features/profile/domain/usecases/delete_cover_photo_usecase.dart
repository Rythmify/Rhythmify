import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

/// Use case that deletes the authenticated user's cover photo.
///
/// Delegates to [ProfileRepository.deleteCoverPhoto].
class DeleteCoverPhotoUseCase {
  /// The repository used to delete the cover photo.
  final ProfileRepository repository;

  /// Creates a [DeleteCoverPhotoUseCase] with the given [repository].
  DeleteCoverPhotoUseCase(this.repository);

  /// Deletes the current user's cover photo.
  ///
  /// Returns [Right] with `void` on success, or [Left] with a [Failure].
  Future<Either<Failure, void>> call({required String userId}) {
    return repository.deleteCoverPhoto(userId: userId);
  }
}
