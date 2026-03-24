import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

/// Use case that deletes the authenticated user's avatar.
///
/// Delegates to [ProfileRepository.deleteAvatar].
class DeleteAvatarUseCase {
  /// The repository used to delete the avatar.
  final ProfileRepository repository;
 
  /// Creates a [DeleteAvatarUseCase] with the given [repository].
  DeleteAvatarUseCase(this.repository);
 
  /// Deletes the current user's avatar image.
  ///
  /// Returns [Right] with `void` on success, or [Left] with a [Failure].
  Future<Either<Failure, void>> call() {
    return repository.deleteAvatar();
  }
}
