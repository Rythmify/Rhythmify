import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

class FollowUserUseCase {
  final ProfileRepository repository;

  FollowUserUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String userId,
  }) {
    return repository.followUser(userId: userId);
  }
}