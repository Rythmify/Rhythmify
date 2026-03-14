import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UploadCoverPhotoUseCase {
  final ProfileRepository repository;

  UploadCoverPhotoUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call({
    required String filePath,
  }) {
    return repository.uploadCoverPhoto(filePath: filePath);
  }
}