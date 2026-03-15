import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class DeleteCoverPhotoUseCase {
  final ProfileRepository repository;

  DeleteCoverPhotoUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.deleteCoverPhoto();
  }
}