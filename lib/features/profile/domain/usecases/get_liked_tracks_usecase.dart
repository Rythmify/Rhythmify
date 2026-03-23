import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/domain/entities/track.dart';
import '../repositories/profile_repository.dart';

/// Use case that fetches a paginated list of tracks liked by a user.
///
/// Delegates to [ProfileRepository.getLikedTracks].
class GetLikedTracksUseCase {
  /// The repository used to fetch liked tracks.
  final ProfileRepository repository;
 
  /// Creates a [GetLikedTracksUseCase] with the given [repository].
  GetLikedTracksUseCase(this.repository);
 
  /// Fetches liked tracks for [userId] at the given [page] and [limit].
  ///
  /// Returns [Right] with a list of [Track] objects (empty when no more
  /// pages exist), or [Left] with a [Failure].
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