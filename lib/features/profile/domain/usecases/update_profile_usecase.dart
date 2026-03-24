import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

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
