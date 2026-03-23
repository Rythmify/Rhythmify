import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';
 
/// Use case that unfollows a user by their ID.
///
/// Delegates to [ProfileRepository.unfollowUser].
class UnfollowUserUseCase {
  /// The repository used to unfollow the user.
  final ProfileRepository repository;
 
  /// Creates an [UnfollowUserUseCase] with the given [repository].
  UnfollowUserUseCase(this.repository);
 
  /// Unfollows the user identified by [userId].
  ///
  /// Returns [Right] with `void` on success, or [Left] with a [Failure].
  Future<Either<Failure, void>> call({required String userId}) {
    return repository.unfollowUser(userId: userId);
  }
}