import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

/// Use case that unblocks a user by their ID.
///
/// Delegates to [ProfileRepository.unblockUser].
class GetUnblockUserUseCase {
  /// The repository used to unblock the user.
  final ProfileRepository repository;

  /// Creates a [GetUnblockUserUseCase] with the given [repository].
  GetUnblockUserUseCase(this.repository);

  /// Unblocks the user identified by [userId].
  ///
  /// Returns [Right] with `void` on success, or [Left] with a [Failure].
  Future<Either<Failure, void>> call({required String userId}) {
    return repository.unblockUser(userId: userId);
  }
}
