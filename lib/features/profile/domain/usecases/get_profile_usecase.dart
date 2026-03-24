import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Use case that fetches a user's profile by their ID.
///
/// Pass `'me'` as [userId] to fetch the authenticated user's own profile.
/// Delegates to [ProfileRepository.getProfile].
class GetProfileUseCase {
  /// The repository used to fetch the profile.
  final ProfileRepository repository;
 
  /// Creates a [GetProfileUseCase] with the given [repository].
  GetProfileUseCase(this.repository);
 
  /// Fetches the profile for [userId].
  ///
  /// Returns [Right] with a [ProfileEntity], or [Left] with a [Failure].
  Future<Either<Failure, ProfileEntity>> call({required String userId}) {
    return repository.getProfile(userId: userId);
  }
}
