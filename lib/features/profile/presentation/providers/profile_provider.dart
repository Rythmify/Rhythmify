import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'profile_state.dart';
import '../../data/datasources/profile_mock_datasource.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/profile_remote_datasource_impl.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../../core/avatar/local_avatar_store.dart';

const bool useProfileMockData = false;

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
  late final FollowUserUseCase _followUser;
  late final UnfollowUserUseCase _unfollowUser;
  late final GetLikedTracksUseCase _getLikedTracks;

  int _currentPage = 1;

  String _resolveUserId(String userId) {
    return userId;
  }

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
    _followUser = FollowUserUseCase(repository);
    _unfollowUser = UnfollowUserUseCase(repository);
    _getLikedTracks = GetLikedTracksUseCase(repository);

    // ── NO auto-load here — initState in each page controls loading ──

    return const ProfileInitial();
  }

  Future<void> loadProfile({required String userId}) async {
    state = const ProfileLoading();
    final resolvedUserId = _resolveUserId(userId);
    final result = await _getProfile(userId: resolvedUserId);
    result.fold((failure) => state = ProfileError(failure.message), (profile) {
      state = ProfileLoaded(profile: profile);
      loadLikedTracks(userId: userId, refresh: true);
    });
  }

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
      userId: _resolveUserId(userId),
      page: _currentPage,
      limit: 20,
    );

    result.fold(
      (failure) {
        if (state is ProfileLoaded) {
          state = (state as ProfileLoaded).copyWith(isLoadingTracks: false);
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
      userId: current.profile.id,
      displayName: displayName,
      city: city,
      country: country,
      bio: bio,
    );

    result.fold((failure) => state = current.copyWith(isSaving: false), (
      profile,
    ) {
      state = current.copyWith(profile: profile, isSaving: false);
      ref.read(authProvider.notifier).refreshAuthenticatedUser();
    });
  }

  Future<void> uploadAvatar({required String filePath}) async {
    print('🔵 ProfileNotifier.uploadAvatar: Called with filePath: $filePath');
    final current = state;
    if (current is! ProfileLoaded) {
      print(
        '🔴 ProfileNotifier.uploadAvatar: State is not ProfileLoaded, aborting',
      );
      return;
    }

    print('🔵 ProfileNotifier.uploadAvatar: Setting isSaving = true');
    state = current.copyWith(isSaving: true);

    print('🔵 ProfileNotifier.uploadAvatar: Calling use case');
    final result = await _uploadAvatar(
      userId: current.profile.id,
      filePath: filePath,
    );
    result.fold(
      (failure) {
        print(
          '🔴 ProfileNotifier.uploadAvatar: Upload failed - ${failure.message}',
        );
        state = current.copyWith(isSaving: false);
      },
      (profile) {
        print('🟢 ProfileNotifier.uploadAvatar: Upload successful!');
        print('🟢 New avatar URL: ${profile.avatarUrl}');

        // Update state - ProfileAvatar widget handles cache clearing
        state = current.copyWith(profile: profile, isSaving: false);
        LocalAvatarStore.set(current.profile.id, filePath);
        ref.invalidate(localAvatarPathProvider(current.profile.id));
        ref.read(authProvider.notifier).refreshAuthenticatedUser();

        print('🟢 Profile state updated with new avatar');
      },
    );
  }

  Future<void> deleteAvatar() async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _deleteAvatar(userId: current.profile.id);
    result.fold(
      (failure) {
        state = current.copyWith(isSaving: false);
      },
      (_) async {
        // Reload profile to get updated avatar URL (null)
        final profileResult = await _getProfile(userId: current.profile.id);
        profileResult.fold(
          (failure) => state = current.copyWith(isSaving: false),
          (profile) {
            state = current.copyWith(profile: profile, isSaving: false);
            LocalAvatarStore.clear(current.profile.id);
            ref.invalidate(localAvatarPathProvider(current.profile.id));
            ref.read(authProvider.notifier).refreshAuthenticatedUser();
          },
        );
      },
    );
  }

  Future<void> uploadCoverPhoto({required String filePath}) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _uploadCoverPhoto(
      userId: current.profile.id,
      filePath: filePath,
    );
    result.fold(
      (failure) {
        state = current.copyWith(isSaving: false);
      },
      (profile) {
        // Update state with new profile containing updated cover
        state = current.copyWith(profile: profile, isSaving: false);
        LocalAvatarStore.setCover(current.profile.id, filePath);
        ref.invalidate(localCoverPathProvider(current.profile.id));
        ref.read(authProvider.notifier).refreshAuthenticatedUser();

        // Force image cache clear to show new cover immediately
        _clearImageCache();
      },
    );
  }

  Future<void> deleteCoverPhoto() async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(isSaving: true);

    final result = await _deleteCoverPhoto(userId: current.profile.id);
    result.fold((failure) => state = current.copyWith(isSaving: false), (_) {
      LocalAvatarStore.clearCover(current.profile.id);
      ref.invalidate(localCoverPathProvider(current.profile.id));
      state = current.copyWith(isSaving: false);
      loadProfile(userId: current.profile.id);
    });
  }

  Future<void> followUser({required String userId}) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(
      profile: current.profile.copyWithFollowing(
        isFollowing: true,
        followersCount: current.profile.followersCount + 1,
      ),
    );

    final result = await _followUser(userId: userId);
    result.fold((failure) => state = current, (_) {});
  }

  Future<void> unfollowUser({required String userId}) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    state = current.copyWith(
      profile: current.profile.copyWithFollowing(
        isFollowing: false,
        followersCount: current.profile.followersCount - 1,
      ),
    );

    final result = await _unfollowUser(userId: userId);
    result.fold((failure) => state = current, (_) {});
  }

  /// Clears the Flutter image cache to force reload of profile images.
  ///
  /// Called after avatar/cover upload to ensure users see the new image
  /// immediately instead of the cached version. This is critical because
  /// CachedNetworkImage aggressively caches images, and even with a new
  /// URL from the backend, Flutter may show the old image.
  void _clearImageCache() {
    // Note: This requires access to PaintingBinding.instance.imageCache
    // which is only available in widgets. For now, the ProfileAvatar widget
    // handles cache-busting via URL timestamp query parameter.
    // If needed, you can pass BuildContext and call:
    // PaintingBinding.instance.imageCache.clear();
    // PaintingBinding.instance.imageCache.clearLiveImages();
  }
}
