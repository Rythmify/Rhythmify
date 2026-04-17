import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_user_summary.dart';
import '../repositories/profile_repository.dart';

/// Connection type enum for profile social lists.
enum ProfileConnectionsType { followers, following }

/// Use case for fetching followers/following users with pagination.
class GetUserConnectionsUseCase {
  /// Repository used to access profile data.
  final ProfileRepository repository;

  /// Creates a [GetUserConnectionsUseCase].
  const GetUserConnectionsUseCase(this.repository);

  /// Fetches a single connections page for the provided [type].
  Future<Either<Failure, List<ProfileUserSummary>>> call({
    required String userId,
    required int page,
    required int limit,
    required ProfileConnectionsType type,
  }) {
    if (type == ProfileConnectionsType.followers) {
      return repository.getFollowers(userId: userId, page: page, limit: limit);
    }
    return repository.getFollowing(userId: userId, page: page, limit: limit);
  }
}
