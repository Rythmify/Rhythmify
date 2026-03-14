import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/track_entity.dart';
import '../repositories/profile_repository.dart';

class GetLikedTracksUseCase {
  final ProfileRepository repository;

  GetLikedTracksUseCase(this.repository);

  Future<Either<Failure, List<TrackEntity>>> call({
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