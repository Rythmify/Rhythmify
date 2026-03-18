import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/track.dart';
import '../repositories/profile_repository.dart';

class GetLikedTracksUseCase {
  final ProfileRepository repository;

  GetLikedTracksUseCase(this.repository);

  Future<Either<Failure, List<Track>>> call({
    required String userId,
    int page = 1,
    int limit = 20,
  }) {
    return repository.getLikedTracks(
      userId: userId,
      page: page,
      limit: limit,
    );
  }
}
