/// Contract for profile-related remote data operations.
import '../models/profile_model.dart';
import '../models/track_model.dart';

abstract class ProfileRemoteDatasource {
  Future<ProfileModel> getProfile({required String userId});

  Future<ProfileModel> updateProfile({
    required String displayName,
    required String city,
    required String country,
    required String bio,
  });

  Future<ProfileModel> uploadAvatar({required String filePath});

  Future<void> deleteAvatar();

  Future<ProfileModel> uploadCoverPhoto({required String filePath});

  Future<void> deleteCoverPhoto();

  Future<void> followUser({required String userId});

  Future<void> unfollowUser({required String userId});

  Future<List<TrackModel>> getLikedTracks({
    required String userId,
    required int page,
    required int limit,
  });
}
