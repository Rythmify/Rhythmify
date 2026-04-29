import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import '../../domain/usecases/delete_avatar_usecase.dart';
import '../../domain/usecases/upload_cover_photo_usecase.dart';
import '../../domain/usecases/delete_cover_photo_usecase.dart';
import '../../domain/usecases/get_follow_user_usecase.dart';
import '../../domain/usecases/get_unfollow_user_usecase.dart';
import '../../domain/usecases/get_follow_status_usecase.dart';
import '../../domain/usecases/get_block_user_usecase.dart';
import '../../domain/usecases/get_unblock_user_usecase.dart';
import '../../domain/usecases/get_liked_tracks_usecase.dart';
import '../../domain/usecases/get_uploaded_tracks_usecase.dart';
import '../../domain/usecases/get_reposted_tracks_usecase.dart';
import '../../domain/usecases/get_user_connections_usecase.dart';
import '../../domain/entities/follow_status.dart';
import 'profile_state.dart';
import '../../data/datasources/profile_mock_datasource.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/profile_remote_datasource_impl.dart';
import '../../.././playlist/data/datasources/playlist_remote_datasource.dart';

// coverage:ignore-file
/// Riverpod providers and notifier orchestration for profile state management.
///
/// Uses separate providers to prevent state flicker:
/// - [ownProfileProvider]: For authenticated user's own profile (`GET /users/me`)
/// - [publicProfileProvider]: Family provider for any user's public profile (`GET /users/{userId}`)

const bool useProfileMockData = false;

final playlistDatasourceProvider = Provider<PlaylistRemoteDatasource>((ref) {
  return PlaylistRemoteDatasource(apiClient.dio);
});

/// Provides the authenticated user's own profile.
///
/// This provider is **independent** from [publicProfileProvider] to prevent
/// flicker when navigating between own profile and other users' profiles.
/// The state is scoped to the authenticated user only.
final ownProfileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

/// Provides a specific user's public profile.
///
/// Family provider keyed by [userId]. Each user ID gets its own state instance.
/// Used for viewing other users' profiles without affecting [ownProfileProvider].
final publicProfileProvider =
    NotifierProvider.family<ProfileNotifier, ProfileState, String>((_) {
      return ProfileNotifier();
    });

/// Legacy provider for backward compatibility.
///
/// **Deprecated**: Use [ownProfileProvider] or [publicProfileProvider] instead.
final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends Notifier<ProfileState> {
  late final GetProfileUseCase _getProfile;
  late final UpdateProfileUseCase _updateProfile;
  late final UploadAvatarUseCase _uploadAvatar;
  late final DeleteAvatarUseCase _deleteAvatar;
  late final UploadCoverPhotoUseCase _uploadCoverPhoto;
  late final DeleteCoverPhotoUseCase _deleteCoverPhoto;
  late final GetFollowUserUseCase _followUser;
  late final GetUnfollowUserUseCase _unfollowUser;
  late final GetLikedTracksUseCase _getLikedTracks;
  late final GetUploadedTracksUseCase _getUploadedTracks;
  late final GetRepostedTracksUseCase _getRepostedTracks;
  late final GetFollowStatusUseCase _getFollowStatus;
  late final GetBlockUserUseCase _blockUser;
  late final GetUnblockUserUseCase _unblockUser;

  int _likesPage = 1;
  int _uploadsPage = 1;
  int _repostsPage = 1;

  // Request Guarding: Track the current request version for each section
  int _likesRequestVersion = 0;
  int _uploadsRequestVersion = 0;
  int _repostsRequestVersion = 0;

  PlaylistRemoteDatasource get _playlistDs =>
      ref.read(playlistDatasourceProvider);

  @override
  ProfileState build() {
    final datasource = useProfileMockData
        ? ProfileMockDatasource()
        : ProfileRemoteDatasourceImpl(client: apiClient);

    final repository = ProfileRepositoryImpl(remoteDatasource: datasource);

    _getProfile = GetProfileUseCase(repository);
    _updateProfile = UpdateProfileUseCase(repository);
    _uploadAvatar = UploadAvatarUseCase(repository);
    _deleteAvatar = DeleteAvatarUseCase(repository);
    _uploadCoverPhoto = UploadCoverPhotoUseCase(repository);
    _deleteCoverPhoto = DeleteCoverPhotoUseCase(repository);
    _followUser = GetFollowUserUseCase(repository);
    _unfollowUser = GetUnfollowUserUseCase(repository);
    _getLikedTracks = GetLikedTracksUseCase(repository);
    _getUploadedTracks = GetUploadedTracksUseCase(repository);
    _getRepostedTracks = GetRepostedTracksUseCase(repository);
    _getFollowStatus = GetFollowStatusUseCase(repository);
    _blockUser = GetBlockUserUseCase(repository);
    _unblockUser = GetUnblockUserUseCase(repository);

    return const ProfileInitial();
  }

  Future<void> loadProfile({required String userId}) async {
    final current = state;
    final isSameUser =
        current is ProfileLoaded &&
        (current.profile.id == userId || userId == 'me');

    // If not the same user, show loading spinner and reset
    if (!isSameUser) {
      state = const ProfileLoading();
    }

    final result = await _getProfile(userId: userId);
    result.fold((failure) => state = ProfileError(failure.message), (profile) {
      if (state is ProfileLoaded &&
          (state as ProfileLoaded).profile.id == profile.id) {
        // Preserve existing tracks but update profile info
        state = (state as ProfileLoaded).copyWith(profile: profile);
      } else {
        // Brand new profile state
        state = ProfileLoaded(profile: profile);
      }
      _loadFollowStatus(userId);
    });
  }

  /// Loads the follow/block status alongside the profile data.
  ///
  /// This must be called before rendering the profile page so the UI
  /// knows whether to show the blocked screen or the real profile.
  Future<void> _loadFollowStatus(String userId) async {
    if (userId == 'me') {
      if (state is ProfileLoaded) {
        state = (state as ProfileLoaded).copyWith(
          followStatus: FollowStatus.empty,
        );
      }
      return;
    }
    final status = await _getFollowStatus(userId);
    if (state is ProfileLoaded) {
      state = (state as ProfileLoaded).copyWith(followStatus: status);
    }
  }

  Future<void> loadPreviews(String userId) async {
    // Load previews (first 3) for all sections sequentially to avoid race conditions
    await loadUploadedTracks(userId: userId, refresh: true, limit: 3);
    await loadLikedTracks(userId: userId, refresh: true, limit: 3);
    await loadRepostedTracks(userId: userId, refresh: true, limit: 3);
    await loadPlaylists(userId: userId, refresh: true, limit: 4);
  }

  Future<void> loadLikedTracks({
    required String userId,
    bool refresh = false,
    int limit = 20,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    // Per-section loading guard
    if (current.isLoadingLikes && !refresh) return;

    // Guard: Increment version for this section
    final requestVersion = ++_likesRequestVersion;

    if (refresh) {
      _likesPage = 1;
      state = current.copyWith(isLoadingLikes: true, hasMoreLikes: true);
    } else {
      if (!current.hasMoreLikes) return;
      state = current.copyWith(isLoadingLikes: true);
    }

    final result = await _getLikedTracks(
      userId: userId,
      page: _likesPage,
      limit: limit,
    );

    // Guard check: Discard if a newer request was started
    if (requestVersion != _likesRequestVersion) return;

    result.fold(
      (failure) {
        if (state is ProfileLoaded) {
          state = (state as ProfileLoaded).copyWith(isLoadingLikes: false);
        }
      },
      (tracks) {
        if (state is ProfileLoaded) {
          final c = state as ProfileLoaded;
          // If refreshing, REPLACE the list. If not, APPEND.
          final updated = refresh ? tracks : [...c.likedTracks, ...tracks];
          _likesPage++;
          state = c.copyWith(
            likedTracks: updated,
            isLoadingLikes: false,
            hasMoreLikes: tracks.length == limit,
          );
        }
      },
    );
  }

  Future<void> loadUploadedTracks({
    required String userId,
    bool refresh = false,
    int limit = 20,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    if (current.isLoadingUploads && !refresh) return;

    // Guard: Increment version
    final requestVersion = ++_uploadsRequestVersion;

    if (refresh) {
      _uploadsPage = 1;
      state = current.copyWith(isLoadingUploads: true, hasMoreUploads: true);
    } else {
      if (!current.hasMoreUploads) return;
      state = current.copyWith(isLoadingUploads: true);
    }

    final result = await _getUploadedTracks(
      userId: userId,
      page: _uploadsPage,
      limit: limit,
    );

    // Guard check
    if (requestVersion != _uploadsRequestVersion) return;

    result.fold(
      (failure) {
        if (state is ProfileLoaded) {
          state = (state as ProfileLoaded).copyWith(isLoadingUploads: false);
        }
      },
      (tracks) {
        if (state is ProfileLoaded) {
          final c = state as ProfileLoaded;
          final updated = refresh ? tracks : [...c.uploadedTracks, ...tracks];
          _uploadsPage++;
          state = c.copyWith(
            uploadedTracks: updated,
            isLoadingUploads: false,
            hasMoreUploads: tracks.length == limit,
          );
        }
      },
    );
  }

  Future<void> loadRepostedTracks({
    required String userId,
    bool refresh = false,
    int limit = 20,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    if (current.isLoadingReposts && !refresh) return;

    // Guard: Increment version
    final requestVersion = ++_repostsRequestVersion;

    if (refresh) {
      _repostsPage = 1;
      state = current.copyWith(isLoadingReposts: true, hasMoreReposts: true);
    } else {
      if (!current.hasMoreReposts) return;
      state = current.copyWith(isLoadingReposts: true);
    }

    final result = await _getRepostedTracks(
      userId: userId,
      page: _repostsPage,
      limit: limit,
    );

    // Guard check
    if (requestVersion != _repostsRequestVersion) return;

    result.fold(
      (failure) {
        if (state is ProfileLoaded) {
          state = (state as ProfileLoaded).copyWith(isLoadingReposts: false);
        }
      },
      (tracks) {
        if (state is ProfileLoaded) {
          final c = state as ProfileLoaded;
          final updated = refresh ? tracks : [...c.repostedTracks, ...tracks];
          _repostsPage++;
          state = c.copyWith(
            repostedTracks: updated,
            isLoadingReposts: false,
            hasMoreReposts: tracks.length == limit,
          );
        }
      },
    );
  }

  Future<void> loadPlaylists({
    required String userId,
    bool refresh = false,
    int limit = 20,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    if (current.isLoadingPlaylists && !refresh) return;

    if (refresh) {
      state = current.copyWith(isLoadingPlaylists: true, playlists: const []);
    } else {
      state = current.copyWith(isLoadingPlaylists: true);
    }

    try {
      final playlists = await _playlistDs.fetchUserPlaylists(
        userId: userId,
        limit: limit,
      );
      if (state is ProfileLoaded) {
        state = (state as ProfileLoaded).copyWith(
          playlists: playlists,
          isLoadingPlaylists: false,
        );
      }
    } catch (e) {
      if (state is ProfileLoaded) {
        state = (state as ProfileLoaded).copyWith(isLoadingPlaylists: false);
      }
    }
  }

  Future<void> updateProfile({
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
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _updateProfile(
      displayName: displayName,
      username: username,
      firstName: firstName,
      lastName: lastName,
      city: city,
      country: country,
      bio: bio,
      instagramUrl: instagramUrl,
      facebookUrl: facebookUrl,
      githubUrl: githubUrl,
    );

    result.fold(
      (failure) => state = current.copyWith(isSaving: false),
      (profile) => state = current.copyWith(profile: profile, isSaving: false),
    );
  }

  Future<void> uploadAvatar({required String filePath}) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _uploadAvatar(filePath: filePath);
    result.fold(
      (failure) {
        state = current.copyWith(isSaving: false);
      },
      (profile) {
        state = current.copyWith(profile: profile, isSaving: false);
      },
    );
  }

  Future<void> deleteAvatar() async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _deleteAvatar();
    result.fold(
      (failure) {
        state = current.copyWith(isSaving: false);
      },
      (_) async {
        final profileResult = await _getProfile(userId: 'me');
        profileResult.fold(
          (failure) => state = current.copyWith(isSaving: false),
          (profile) =>
              state = current.copyWith(profile: profile, isSaving: false),
        );
      },
    );
  }

  Future<void> uploadCoverPhoto({required String filePath}) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _uploadCoverPhoto(filePath: filePath);
    result.fold(
      (failure) {
        state = current.copyWith(isSaving: false);
      },
      (profile) {
        state = current.copyWith(profile: profile, isSaving: false);
      },
    );
  }

  Future<void> deleteCoverPhoto() async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _deleteCoverPhoto();
    result.fold((failure) => state = current.copyWith(isSaving: false), (_) {
      state = current.copyWith(isSaving: false);
      loadProfile(userId: 'me');
    });
  }

  /// Starts following a user.
  ///
  /// Calls the follow API and then refreshes the profile state to get
  /// the updated followers count from the backend. Returns early if already
  /// following or if state is not loaded.
  Future<void> followUser({required String userId}) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    if (current.profile.isFollowing) return;

    final result = await _followUser(userId: userId);
    if (result.isRight()) {
      state = current.copyWith(
        profile: current.profile.copyWith(
          isFollowing: true,
          followersCount: current.profile.followersCount + 1,
        ),
      );
      _updateOwnFollowingCount(1);
    } else {
      state = current;
    }
  }

  /// Stops following a user.
  ///
  /// Calls the unfollow API and then refreshes the profile state to get
  /// the updated followers count from the backend. Returns early if not
  /// following or if state is not loaded.
  Future<void> unfollowUser({required String userId}) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    if (!current.profile.isFollowing) return;

    final result = await _unfollowUser(userId: userId);
    if (result.isRight()) {
      state = current.copyWith(
        profile: current.profile.copyWith(
          isFollowing: false,
          followersCount: (current.profile.followersCount - 1).clamp(0, 999999),
        ),
      );
      _updateOwnFollowingCount(-1);
    } else {
      state = current;
    }
  }

  void _updateOwnFollowingCount(int delta) {
    final ownState = ref.read(ownProfileProvider);
    if (ownState is! ProfileLoaded) return;
    final nextCount = ownState.profile.followingCount + delta;
    ref.read(ownProfileProvider.notifier).state = ownState.copyWith(
      profile: ownState.profile.copyWith(
        followingCount: nextCount < 0 ? 0 : nextCount,
      ),
    );
  }

  void syncConnectionsCount({
    required ProfileConnectionsType type,
    required int count,
  }) {
    final current = state;
    if (current is! ProfileLoaded) return;
    final safeCount = count < 0 ? 0 : count;
    state = current.copyWith(
      profile: type == ProfileConnectionsType.followers
          ? current.profile.copyWith(followersCount: safeCount)
          : current.profile.copyWith(followingCount: safeCount),
    );
  }

  void blockUser(String userId, {void Function(String message)? onError}) {
    if (state is! ProfileLoaded) return;

    final current = state as ProfileLoaded;
    state = current.copyWith(
      isBlocked: true,
      followStatus: current.followStatus.copyWith(
        isBlocking: true,
        isFollowing: false,
        isFollowedBy: false,
      ),
    );

    unawaited(
      _blockUser(userId: userId).then((result) {
        result.fold((failure) => onError?.call(failure.message), (_) {});
      }),
    );
  }

  Future<void> unblockUser(String userId) async {
    // ── Optimistic Update ──────────────────────────────────────────────────
    // Immediately hide the blocked screen.
    final previous = state;
    if (state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      state = current.copyWith(
        followStatus: current.followStatus.copyWith(isBlocking: false),
      );
    }

    final result = await _unblockUser(userId: userId);

    if (result.isLeft()) {
      // Rollback on failure
      state = previous;
    } else {
      // Final sync with backend
      await _loadFollowStatus(userId);
    }
  }
}
