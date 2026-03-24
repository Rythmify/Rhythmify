import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Use case that updates the authenticated user's profile fields.
///
/// Delegates to [ProfileRepository.updateProfile].
class UpdateProfileUseCase {
  /// The repository used to update the profile.
  final ProfileRepository repository;

  /// Creates an [UpdateProfileUseCase] with the given [repository].
  UpdateProfileUseCase(this.repository);

  /// Updates the profile with the given fields.
  ///
  /// [displayName], [city], [country] (ISO alpha-2), and [bio].
  /// Returns [Right] with updated [ProfileEntity], or [Left] with a [Failure].
  Future<Either<Failure, ProfileEntity>> call({
    required String displayName,
    required String city,
    required String country,
    required String bio,
  }) {
    return repository.updateProfile(
      displayName: displayName,
      city: city,
      country: country,
      bio: bio,
    );
  }
}
