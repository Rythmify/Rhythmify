import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/profile_mock_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import '../../domain/usecases/delete_avatar_usecase.dart';
import '../../domain/usecases/upload_cover_photo_usecase.dart';
import '../../domain/usecases/delete_cover_photo_usecase.dart';
import '../../domain/usecases/follow_user_usecase.dart';
import '../../domain/usecases/unfollow_user_usecase.dart';
import '../../domain/usecases/get_liked_tracks_usecase.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../../features/authentication/presentation/providers/auth_state.dart';
import 'profile_state.dart';

final profileProvider =
    NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends Notifier<ProfileState> {
  late final GetProfileUseCase _getProfile;
  late final UpdateProfileUseCase _updateProfile;
  late final UploadAvatarUseCase _uploadAvatar;
  late final DeleteAvatarUseCase _deleteAvatar;
  late final UploadCoverPhotoUseCase _uploadCoverPhoto;
  late final DeleteCoverPhotoUseCase _deleteCoverPhoto;
  late final FollowUserUseCase _followUser;
  late final UnfollowUserUseCase _unfollowUser;
  late final GetLikedTracksUseCase _getLikedTracks;

  int _currentPage = 1;

  @override
  ProfileState build() {
    final authState = ref.watch(authProvider);

    // ── Switch to real datasource when backend is ready ──────────────
    // final datasource = ProfileRemoteDatasourceImpl(client: apiClient);
    final datasource = ProfileMockDatasource();

    final repository = ProfileRepositoryImpl(remoteDatasource: datasource);

    _getProfile = GetProfileUseCase(repository);
    _updateProfile = UpdateProfileUseCase(repository);
    _uploadAvatar = UploadAvatarUseCase(repository);
    _deleteAvatar = DeleteAvatarUseCase(repository);
    _uploadCoverPhoto = UploadCoverPhotoUseCase(repository);
    _deleteCoverPhoto = DeleteCoverPhotoUseCase(repository);
    _followUser = FollowUserUseCase(repository);
    _unfollowUser = UnfollowUserUseCase(repository);
    _getLikedTracks = GetLikedTracksUseCase(repository);

    // ── Set current user in mock based on who is logged in ───────────
    if (authState is AuthAuthenticated) {
      ProfileMockDatasource.setCurrentUser(authState.user.id);
      Future.microtask(() => loadProfile(userId: authState.user.id));
    }

    return const ProfileInitial();
  }

  // ── Load profile ──────────────────────────────────────────────────
  Future<void> loadProfile({required String userId}) async {
    state = const ProfileLoading();
    final result = await _getProfile(userId: userId);
    result.fold(
      (failure) => state = ProfileError(failure.message),
      (profile) {
        state = ProfileLoaded(profile: profile);
        loadLikedTracks(userId: userId, refresh: true);
      },
    );
  }

  // ── Load liked tracks with pagination ─────────────────────────────
  Future<void> loadLikedTracks({
    required String userId,
    bool refresh = false,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    if (current.isLoadingTracks) return;

    if (refresh) {
      _currentPage = 1;
      state = current.copyWith(
        likedTracks: [],
        isLoadingTracks: true,
        hasMoreTracks: true,
      );
    } else {
      if (!current.hasMoreTracks) return;
      state = current.copyWith(isLoadingTracks: true);
    }

    final result = await _getLikedTracks(
      userId: userId,
      page: _currentPage,
      limit: 20,
    );

    result.fold(
      (failure) {
        if (state is ProfileLoaded) {
          state = (state as ProfileLoaded).copyWith(
            isLoadingTracks: false,
          );
        }
      },
      (tracks) {
        if (state is ProfileLoaded) {
          final current = state as ProfileLoaded;
          final updated = refresh
              ? tracks
              : [...current.likedTracks, ...tracks];
          _currentPage++;
          state = current.copyWith(
            likedTracks: updated,
            isLoadingTracks: false,
            hasMoreTracks: tracks.length == 20,
          );
        }
      },
    );
  }

  // ── Update profile ────────────────────────────────────────────────
  Future<void> updateProfile({
    required String displayName,
    required String city,
    required String country,
    required String bio,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _updateProfile(
      displayName: displayName,
      city: city,
      country: country,
      bio: bio,
    );

    result.fold(
      (failure) => state = current.copyWith(isSaving: false),
      (profile) => state = current.copyWith(
        profile: profile,
        isSaving: false,
      ),
    );
  }

  // ── Upload avatar ─────────────────────────────────────────────────
  Future<void> uploadAvatar({required String filePath}) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _uploadAvatar(filePath: filePath);
    result.fold(
      (failure) => state = current.copyWith(isSaving: false),
      (profile) => state = current.copyWith(
        profile: profile,
        isSaving: false,
      ),
    );
  }

  // ── Delete avatar ─────────────────────────────────────────────────
  Future<void> deleteAvatar() async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _deleteAvatar();
    result.fold(
      (failure) => state = current.copyWith(isSaving: false),
      (_) => state = current.copyWith(
        profile: current.profile.copyWithFollowing(
          isFollowing: current.profile.isFollowing,
          followersCount: current.profile.followersCount,
        ),
        isSaving: false,
      ),
    );
  }

  // ── Upload cover photo ────────────────────────────────────────────
  Future<void> uploadCoverPhoto({required String filePath}) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _uploadCoverPhoto(filePath: filePath);
    result.fold(
      (failure) => state = current.copyWith(isSaving: false),
      (profile) => state = current.copyWith(
        profile: profile,
        isSaving: false,
      ),
    );
  }

  // ── Delete cover photo ────────────────────────────────────────────
  Future<void> deleteCoverPhoto() async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _deleteCoverPhoto();
    result.fold(
      (failure) => state = current.copyWith(isSaving: false),
      (_) => state = current.copyWith(isSaving: false),
    );
  }

  // ── Follow user ───────────────────────────────────────────────────
  Future<void> followUser({required String userId}) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    // Optimistic update
    state = current.copyWith(
      profile: current.profile.copyWithFollowing(
        isFollowing: true,
        followersCount: current.profile.followersCount + 1,
      ),
    );

    final result = await _followUser(userId: userId);
    result.fold(
      // Rollback on failure
      (failure) => state = current,
      (_) {},
    );
  }

  // ── Unfollow user ─────────────────────────────────────────────────
  Future<void> unfollowUser({required String userId}) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    // Optimistic update
    state = current.copyWith(
      profile: current.profile.copyWithFollowing(
        isFollowing: false,
        followersCount: current.profile.followersCount - 1,
      ),
    );

    final result = await _unfollowUser(userId: userId);
    result.fold(
      // Rollback on failure
      (failure) => state = current,
      (_) {},
    );
  }
}