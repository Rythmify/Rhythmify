import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class UnfollowUserUseCase {
  final ProfileRepository repository;

  UnfollowUserUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
  }) {
    return repository.unfollowUser(userId: userId);
  }
}