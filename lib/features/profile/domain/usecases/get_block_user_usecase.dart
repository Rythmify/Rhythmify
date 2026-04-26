import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

/// Use case that blocks a user by their ID.
///
/// Delegates to [ProfileRepository.blockUser].
class GetBlockUserUseCase {
  /// The repository used to block the user.
  final ProfileRepository repository;

  /// Creates a [GetBlockUserUseCase] with the given [repository].
  GetBlockUserUseCase(this.repository);

  /// Blocks the user identified by [userId].
  ///
  /// Returns [Right] with `void` on success, or [Left] with a [Failure].
  Future<Either<Failure, void>> call({required String userId}) {
    return repository.blockUser(userId: userId);
  }
}
