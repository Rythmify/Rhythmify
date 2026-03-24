import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class DeleteAvatarUseCase {
  final ProfileRepository repository;

  DeleteAvatarUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.deleteAvatar();
  }
}
