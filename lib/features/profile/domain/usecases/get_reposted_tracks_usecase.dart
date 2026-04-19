import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/track.dart';
import '../repositories/profile_repository.dart';

class GetRepostedTracksUseCase {
  final ProfileRepository repository;

  GetRepostedTracksUseCase(this.repository);

  Future<Either<Failure, List<Track>>> call({
    required String userId,
    int page = 1,
    int limit = 20,
  }) {
    return repository.getRepostedTracks(
      userId: userId,
      page: page,
      limit: limit,
    );
  }
}
