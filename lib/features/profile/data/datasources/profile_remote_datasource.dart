import '../models/profile_model.dart';
import '../models/profile_user_summary_model.dart';
import '../models/track_model.dart';
import '../models/follow_status_model.dart';
import '../../../playlist/domain/entities/playlist_entity.dart';

/// Contract for profile-related remote data operations.
abstract class ProfileRemoteDatasource {
  Future<ProfileModel> getProfile({required String userId});

  Future<FollowStatusModel> getFollowStatus(String userId);

  Future<ProfileModel> updateProfile({
    required String displayName,
    required String username,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String bio,
    String? instagramUrl,
    String? facebookUrl,
    String? githubUrl,
  });

  Future<ProfileModel> uploadAvatar({required String filePath});

  Future<void> deleteAvatar();

  Future<ProfileModel> uploadCoverPhoto({required String filePath});

  Future<void> deleteCoverPhoto();

  Future<void> followUser({required String userId});

  Future<void> unfollowUser({required String userId});

  Future<void> blockUser({required String userId});

  Future<void> unblockUser({required String userId});

  Future<List<TrackModel>> getLikedTracks({
    required String userId,
    required int page,
    required int limit,
  });

  Future<List<TrackModel>> getUploadedTracks({
    required String userId,
    required int page,
    required int limit,
  });

  Future<List<TrackModel>> getRepostedTracks({
    required String userId,
    required int page,
    required int limit,
  });

  /// Fetches a paginated followers list for a profile.
  Future<List<ProfileUserSummaryModel>> getFollowers({
    required String userId,
    required int page,
    required int limit,
  });

  /// Fetches a paginated following list for a profile.
  Future<List<ProfileUserSummaryModel>> getFollowing({
    required String userId,
    required int page,
    required int limit,
  });

  /// Fetches albums (playlists) for a user.
  /// Uses `mine=true` for 'me', otherwise `owner_user_id={userId}`.
  Future<List<PlaylistEntity>> getAlbums({
    required String userId,
    required int limit,
  });
}
