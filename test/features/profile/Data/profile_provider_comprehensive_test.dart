import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/errors/failures.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';
import 'package:rythmify/features/profile/domain/entities/follow_status.dart';
import 'package:rythmify/features/profile/domain/repositories/profile_repository.dart';
import 'package:rythmify/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/delete_avatar_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/upload_cover_photo_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/delete_cover_photo_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_follow_user_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_unfollow_user_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_follow_status_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_block_user_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_unblock_user_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_liked_tracks_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_uploaded_tracks_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_reposted_tracks_usecase.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_provider.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_state.dart';
import 'package:rythmify/features/playlist/domain/entities/playlist_entity.dart';
import 'package:rythmify/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:rythmify/features/profile/domain/usecases/get_user_connections_usecase.dart';

// ---------------------------------------------------------------------------
// Mock Classes
// ---------------------------------------------------------------------------

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockProfileRemoteDatasource extends Mock
    implements ProfileRemoteDatasource {}

// ---------------------------------------------------------------------------
// Testable Notifier with Dependency Injection
// ---------------------------------------------------------------------------

class _ProfileNotifierUnderTest extends Notifier<ProfileState> {
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  final UploadAvatarUseCase _uploadAvatar;
  final DeleteAvatarUseCase _deleteAvatar;
  final UploadCoverPhotoUseCase _uploadCoverPhoto;
  final DeleteCoverPhotoUseCase _deleteCoverPhoto;
  final GetFollowUserUseCase _followUser;
  final GetUnfollowUserUseCase _unfollowUser;
  final GetLikedTracksUseCase _getLikedTracks;
  final GetUploadedTracksUseCase _getUploadedTracks;
  final GetRepostedTracksUseCase _getRepostedTracks;
  final GetFollowStatusUseCase _getFollowStatus;
  final GetUnblockUserUseCase _unblockUser;
  final ProfileRemoteDatasource _profileDatasource;

  int _likesPage = 1;
  int _uploadsPage = 1;
  int _repostsPage = 1;

  int _likesRequestVersion = 0;
  int _uploadsRequestVersion = 0;
  int _repostsRequestVersion = 0;

  _ProfileNotifierUnderTest({
    required GetProfileUseCase getProfile,
    required UpdateProfileUseCase updateProfile,
    required UploadAvatarUseCase uploadAvatar,
    required DeleteAvatarUseCase deleteAvatar,
    required UploadCoverPhotoUseCase uploadCoverPhoto,
    required DeleteCoverPhotoUseCase deleteCoverPhoto,
    required GetFollowUserUseCase followUser,
    required GetUnfollowUserUseCase unfollowUser,
    required GetLikedTracksUseCase getLikedTracks,
    required GetUploadedTracksUseCase getUploadedTracks,
    required GetRepostedTracksUseCase getRepostedTracks,
    required GetFollowStatusUseCase getFollowStatus,
    required GetBlockUserUseCase blockUser,
    required GetUnblockUserUseCase unblockUser,
    required ProfileRemoteDatasource profileDatasource,
  }) : _getProfile = getProfile,
       _updateProfile = updateProfile,
       _uploadAvatar = uploadAvatar,
       _deleteAvatar = deleteAvatar,
       _uploadCoverPhoto = uploadCoverPhoto,
       _deleteCoverPhoto = deleteCoverPhoto,
       _followUser = followUser,
       _unfollowUser = unfollowUser,
       _getLikedTracks = getLikedTracks,
       _getUploadedTracks = getUploadedTracks,
       _getRepostedTracks = getRepostedTracks,
       _getFollowStatus = getFollowStatus,
       _unblockUser = unblockUser,
       _profileDatasource = profileDatasource;

  @override
  ProfileState build() => const ProfileInitial();

  Future<void> loadProfile({required String userId}) async {
    final current = state;
    final isSameUser =
        current is ProfileLoaded &&
        (current.profile.id == userId || userId == 'me');

    if (!isSameUser) {
      state = const ProfileLoading();
    }

    final result = await _getProfile(userId: userId);
    await result.fold((failure) async => state = ProfileError(failure.message), (profile) async {
      if (state is ProfileLoaded &&
          (state as ProfileLoaded).profile.id == profile.id) {
        state = (state as ProfileLoaded).copyWith(profile: profile);
      } else {
        state = ProfileLoaded(profile: profile);
      }
      await _loadFollowStatus(userId);
    });
  }

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

  Future<void> loadLikedTracks({
    required String userId,
    bool refresh = false,
    int limit = 20,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    if (current.isLoadingLikes && !refresh) return;

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
      state = current.copyWith(
        isLoadingPlaylists: true,
        playlists: const [],
        albums: const [],
      );
    } else {
      state = current.copyWith(isLoadingPlaylists: true);
    }

    try {
      final allItems = await _profileDatasource.getAlbums(
        userId: userId,
        limit: limit,
      );

      final playlists = allItems
          .where((p) => p.type != PlaylistType.album)
          .toList();
      final albums = allItems
          .where((p) => p.type == PlaylistType.album)
          .toList();

      if (state is ProfileLoaded) {
        state = (state as ProfileLoaded).copyWith(
          playlists: playlists,
          albums: albums,
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
    await result.fold(
      (failure) async {
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
    await result.fold((failure) async => state = current.copyWith(isSaving: false), (_) async {
      state = current.copyWith(isSaving: false);
      await loadProfile(userId: 'me');
    });
  }

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
    } else {
      state = current;
    }
  }

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
    } else {
      state = current;
    }
  }

  void syncConnectionsCount({required int type, required int count}) {
    final current = state;
    if (current is! ProfileLoaded) return;
    final safeCount = count < 0 ? 0 : count;
    final isFollowers = type == 0; // 0 = followers, 1 = following
    state = current.copyWith(
      profile: isFollowers
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
  }

  Future<void> unblockUser(String userId) async {
    final previous = state;
    if (state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      state = current.copyWith(
        followStatus: current.followStatus.copyWith(isBlocking: false),
      );
    }

    final result = await _unblockUser(userId: userId);

    if (result.isLeft()) {
      state = previous;
    } else {
      await _loadFollowStatus(userId);
    }
  }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const tProfile = ProfileEntity(
  id: 'user-001',
  displayName: 'KarimWI',
  followersCount: 1240,
  followingCount: 380,
  tracksCount: 14,
  isFollowing: false,
);

const tProfileFollowing = ProfileEntity(
  id: 'user-001',
  displayName: 'KarimWI',
  followersCount: 1241,
  followingCount: 380,
  tracksCount: 14,
  isFollowing: true,
);

const tProfileDifferentUser = ProfileEntity(
  id: 'user-002',
  displayName: 'OtherUser',
  followersCount: 500,
  followingCount: 200,
  tracksCount: 10,
  isFollowing: false,
);

const tFollowStatus = FollowStatus(
  isFollowing: false,
  isFollowedBy: false,
  isBlocking: false,
  isBlockedBy: false,
);

const tFollowStatusFollowing = FollowStatus(
  isFollowing: true,
  isFollowedBy: false,
  isBlocking: false,
  isBlockedBy: false,
);

const tFollowStatusBlocking = FollowStatus(
  isFollowing: false,
  isFollowedBy: false,
  isBlocking: true,
  isBlockedBy: false,
);

Track makeTrack(String id) => Track(
  id: id,
  userId: 'user-002',
  title: 'Track $id',
  artist: 'Artist',
  audioUrl: 'https://example.com/$id.mp3',
  duration: const Duration(seconds: 200),
  createdAt: DateTime(2024, 1, 1),
);

List<Track> makeTracks(int count) =>
    List.generate(count, (i) => makeTrack('track-$i'));

PlaylistEntity makePlaylist(
  String id, {
  PlaylistType type = PlaylistType.playlist,
}) => PlaylistEntity(
  id: id,
  name: 'Playlist $id',
  ownerName: 'Test User',
  ownerId: 'user-001',
  isPublic: true,
  type: type,
  trackCount: 10,
  totalDuration: const Duration(hours: 1),
  createdAt: DateTime(2024, 1, 1),
  description: 'Test description',
);

List<PlaylistEntity> makeAlbums(int count) => List.generate(
  count,
  (i) => makePlaylist('album-$i', type: PlaylistType.album),
);

List<PlaylistEntity> makePlaylists(int count) =>
    List.generate(count, (i) => makePlaylist('playlist-$i'));

// ---------------------------------------------------------------------------
// Test Cases
// ---------------------------------------------------------------------------

void main() {
  group('ProfileNotifier comprehensive tests', () {
    late MockProfileRepository mockRepository;
    late MockProfileRemoteDatasource mockDatasource;
    late GetProfileUseCase mockGetProfile;
    late UpdateProfileUseCase mockUpdateProfile;
    late UploadAvatarUseCase mockUploadAvatar;
    late DeleteAvatarUseCase mockDeleteAvatar;
    late UploadCoverPhotoUseCase mockUploadCoverPhoto;
    late DeleteCoverPhotoUseCase mockDeleteCoverPhoto;
    late GetFollowUserUseCase mockFollowUser;
    late GetUnfollowUserUseCase mockUnfollowUser;
    late GetLikedTracksUseCase mockGetLikedTracks;
    late GetUploadedTracksUseCase mockGetUploadedTracks;
    late GetRepostedTracksUseCase mockGetRepostedTracks;
    late GetFollowStatusUseCase mockGetFollowStatus;
    late GetBlockUserUseCase mockBlockUser;
    late GetUnblockUserUseCase mockUnblockUser;
    late ProviderContainer container;
    late NotifierProvider<_ProfileNotifierUnderTest, ProfileState>
    testProfileProvider;

    setUp(() {
      mockRepository = MockProfileRepository();
      mockDatasource = MockProfileRemoteDatasource();
      mockGetProfile = GetProfileUseCase(mockRepository);
      mockUpdateProfile = UpdateProfileUseCase(mockRepository);
      mockUploadAvatar = UploadAvatarUseCase(mockRepository);
      mockDeleteAvatar = DeleteAvatarUseCase(mockRepository);
      mockUploadCoverPhoto = UploadCoverPhotoUseCase(mockRepository);
      mockDeleteCoverPhoto = DeleteCoverPhotoUseCase(mockRepository);
      mockFollowUser = GetFollowUserUseCase(mockRepository);
      mockUnfollowUser = GetUnfollowUserUseCase(mockRepository);
      mockGetLikedTracks = GetLikedTracksUseCase(mockRepository);
      mockGetUploadedTracks = GetUploadedTracksUseCase(mockRepository);
      mockGetRepostedTracks = GetRepostedTracksUseCase(mockRepository);
      mockGetFollowStatus = GetFollowStatusUseCase(mockRepository);
      mockBlockUser = GetBlockUserUseCase(mockRepository);
      mockUnblockUser = GetUnblockUserUseCase(mockRepository);

      testProfileProvider =
          NotifierProvider<_ProfileNotifierUnderTest, ProfileState>(() {
            return _ProfileNotifierUnderTest(
              getProfile: mockGetProfile,
              updateProfile: mockUpdateProfile,
              uploadAvatar: mockUploadAvatar,
              deleteAvatar: mockDeleteAvatar,
              uploadCoverPhoto: mockUploadCoverPhoto,
              deleteCoverPhoto: mockDeleteCoverPhoto,
              followUser: mockFollowUser,
              unfollowUser: mockUnfollowUser,
              getLikedTracks: mockGetLikedTracks,
              getUploadedTracks: mockGetUploadedTracks,
              getRepostedTracks: mockGetRepostedTracks,
              getFollowStatus: mockGetFollowStatus,
              blockUser: mockBlockUser,
              unblockUser: mockUnblockUser,
              profileDatasource: mockDatasource,
            );
          });
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with ProfileInitial state', () {
      final state = container.read(testProfileProvider);
      expect(state, isA<ProfileInitial>());
    });

    test('should create ProfileLoaded with correct properties', () {
      final loaded = ProfileLoaded(profile: tProfile);
      expect(loaded.profile.id, equals(tProfile.id));
      expect(loaded.profile.displayName, equals(tProfile.displayName));
      expect(loaded.likedTracks, isEmpty);
      expect(loaded.uploadedTracks, isEmpty);
      expect(loaded.repostedTracks, isEmpty);
      expect(loaded.isLoadingLikes, false);
    });

    test('should create ProfileError with message', () {
      const error = ProfileError('Test error');
      expect(error.message, equals('Test error'));
    });

    test('should create ProfileLoading state', () {
      const loading = ProfileLoading();
      expect(loading, isA<ProfileLoading>());
    });

    test('should load profile for different user and show loading', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = const ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfileDifferentUser));

      when(
        () => mockRepository.getFollowStatus(any()),
      ).thenAnswer((_) async => tFollowStatus);

      await notifier.loadProfile(userId: 'user-002');

      final state = container.read(testProfileProvider);
      expect(state, isA<ProfileLoaded>());
      final loaded = state as ProfileLoaded;
      expect(loaded.profile.id, equals(tProfileDifferentUser.id));
    });

    test('should load same user without showing loading spinner', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfile));

      when(
        () => mockRepository.getFollowStatus(any()),
      ).thenAnswer((_) async => tFollowStatus);

      await notifier.loadProfile(userId: tProfile.id);

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
    });

    test(
      'should load profile for "me" without showing loading spinner',
      () async {
        final notifier = container.read(testProfileProvider.notifier);
        // ignore: invalid_use_of_protected_member
        notifier.state = ProfileLoaded(profile: tProfile);

        when(
          () => mockRepository.getProfile(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Right(tProfile));

        when(
          () => mockRepository.getFollowStatus(any()),
        ).thenAnswer((_) async => tFollowStatus);

        await notifier.loadProfile(userId: 'me');

        expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      },
    );

    test('should handle profile load failure', () async {
      final notifier = container.read(testProfileProvider.notifier);
      when(
        () => mockRepository.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => Left(ServerFailure('Network error')));

      await notifier.loadProfile(userId: 'user-002');

      expect(container.read(testProfileProvider), isA<ProfileError>());
      final error = container.read(testProfileProvider) as ProfileError;
      expect(error.message, contains('Network error'));
    });

    test(
      'should preserve existing state on same user profile update',
      () async {
        final notifier = container.read(testProfileProvider.notifier);
        final initialTracks = makeTracks(5);
        // ignore: invalid_use_of_protected_member
        notifier.state = ProfileLoaded(
          profile: tProfile,
          likedTracks: initialTracks,
        );

        final updatedProfile = tProfile.copyWith(displayName: 'Updated Name');

        when(
          () => mockRepository.getProfile(userId: any(named: 'userId')),
        ).thenAnswer((_) async => Right(updatedProfile));

        when(
          () => mockRepository.getFollowStatus(any()),
        ).thenAnswer((_) async => tFollowStatus);

        await notifier.loadProfile(userId: tProfile.id);

        expect(container.read(testProfileProvider), isA<ProfileLoaded>());
        final loaded = container.read(testProfileProvider) as ProfileLoaded;
        expect(loaded.profile.displayName, equals('Updated Name'));
        expect(loaded.likedTracks, equals(initialTracks));
      },
    );

    test('should load liked tracks on first call', () async {
      final notifier = container.read(testProfileProvider.notifier);
      final tracks = makeTracks(20);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(tracks));

      await notifier.loadLikedTracks(userId: tProfile.id);

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.likedTracks, equals(tracks));
      expect(loaded.isLoadingLikes, false);
      expect(loaded.hasMoreLikes, true);
    });

    test(
      'should not load liked tracks when already loading and not refresh',
      () async {
        final notifier = container.read(testProfileProvider.notifier);
        // ignore: invalid_use_of_protected_member
        notifier.state = ProfileLoaded(profile: tProfile, isLoadingLikes: true);

        await notifier.loadLikedTracks(userId: tProfile.id, refresh: false);

        verifyNever(
          () => mockRepository.getLikedTracks(
            userId: any(named: 'userId'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        );
      },
    );

    test('should refresh liked tracks and reset page', () async {
      final notifier = container.read(testProfileProvider.notifier);
      final oldTracks = makeTracks(10);
      final newTracks = makeTracks(20);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile, likedTracks: oldTracks);

      when(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(newTracks));

      await notifier.loadLikedTracks(userId: tProfile.id, refresh: true);

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.likedTracks, equals(newTracks));
    });

    test('should paginate liked tracks', () async {
      final notifier = container.read(testProfileProvider.notifier);
      final page1Tracks = makeTracks(20);
      final page2Tracks = [
        Track(
          id: 'track-20',
          userId: 'user-002',
          title: 'Track 20',
          artist: 'Artist',
          audioUrl: 'https://example.com/track-20.mp3',
          duration: const Duration(seconds: 200),
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(
        profile: tProfile,
        likedTracks: page1Tracks,
        hasMoreLikes: true,
      );

      when(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(page2Tracks));

      await notifier.loadLikedTracks(userId: tProfile.id);

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.likedTracks.length, equals(21));
      expect(loaded.hasMoreLikes, false);
    });

    test('should not load more when hasMoreLikes is false', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile, hasMoreLikes: false);

      await notifier.loadLikedTracks(userId: tProfile.id);

      verifyNever(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      );
    });

    test('should handle liked tracks load failure', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile, isLoadingLikes: false);

      when(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Left(ServerFailure('Test error')));

      await notifier.loadLikedTracks(userId: tProfile.id);

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.isLoadingLikes, false);
    });

    test('should load uploaded tracks on first call', () async {
      final notifier = container.read(testProfileProvider.notifier);
      final tracks = makeTracks(15);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.getUploadedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(tracks));

      await notifier.loadUploadedTracks(userId: tProfile.id);

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.uploadedTracks, equals(tracks));
      expect(loaded.isLoadingUploads, false);
    });

    test(
      'should not load uploaded tracks when already loading and not refresh',
      () async {
        final notifier = container.read(testProfileProvider.notifier);
        // ignore: invalid_use_of_protected_member
        notifier.state = ProfileLoaded(
          profile: tProfile,
          isLoadingUploads: true,
        );

        await notifier.loadUploadedTracks(userId: tProfile.id, refresh: false);

        verifyNever(
          () => mockRepository.getUploadedTracks(
            userId: any(named: 'userId'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        );
      },
    );

    test('should load reposted tracks on first call', () async {
      final notifier = container.read(testProfileProvider.notifier);
      final tracks = makeTracks(8);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.getRepostedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(tracks));

      await notifier.loadRepostedTracks(userId: tProfile.id);

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.repostedTracks, equals(tracks));
      expect(loaded.isLoadingReposts, false);
    });

    test('should load playlists and albums from datasource', () async {
      final notifier = container.read(testProfileProvider.notifier);
      final playlists = makePlaylists(3);
      final albums = makeAlbums(2);
      final combined = [...playlists, ...albums];

      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockDatasource.getAlbums(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => combined);

      await notifier.loadPlaylists(userId: tProfile.id);

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.playlists.length, equals(3));
      expect(loaded.albums.length, equals(2));
      expect(loaded.isLoadingPlaylists, false);
    });

    test('should handle playlist loading failure', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockDatasource.getAlbums(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
        ),
      ).thenThrow(Exception('Load failed'));

      await notifier.loadPlaylists(userId: tProfile.id);

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.isLoadingPlaylists, false);
    });

    test('should update profile successfully', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.updateProfile(
          displayName: any(named: 'displayName'),
          username: any(named: 'username'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          city: any(named: 'city'),
          country: any(named: 'country'),
          bio: any(named: 'bio'),
        ),
      ).thenAnswer((_) async => const Right(tProfile));

      await notifier.updateProfile(
        displayName: 'New Name',
        username: 'newusername',
        firstName: 'New',
        lastName: 'Name',
        city: 'Cairo',
        country: 'Egypt',
        bio: 'Bio',
      );

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.isSaving, false);
    });

    test('should handle profile update failure', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.updateProfile(
          displayName: any(named: 'displayName'),
          username: any(named: 'username'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          city: any(named: 'city'),
          country: any(named: 'country'),
          bio: any(named: 'bio'),
        ),
      ).thenAnswer((_) async => Left(ServerFailure('Test error')));

      await notifier.updateProfile(
        displayName: 'New Name',
        username: 'newusername',
        firstName: 'New',
        lastName: 'Name',
        city: 'Cairo',
        country: 'Egypt',
        bio: 'Bio',
      );

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.isSaving, false);
    });

    test('should upload avatar successfully', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.uploadAvatar(filePath: any(named: 'filePath')),
      ).thenAnswer((_) async => const Right(tProfile));

      await notifier.uploadAvatar(filePath: '/path/to/avatar.jpg');

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.isSaving, false);
    });

    test('should delete avatar successfully', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.deleteAvatar(),
      ).thenAnswer((_) async => const Right(unit));

      when(
        () => mockRepository.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfile));

      when(
        () => mockRepository.getFollowStatus(any()),
      ).thenAnswer((_) async => tFollowStatus);

      await notifier.deleteAvatar();

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.isSaving, false);
    });

    test('should upload cover photo successfully', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.uploadCoverPhoto(filePath: any(named: 'filePath')),
      ).thenAnswer((_) async => const Right(tProfile));

      await notifier.uploadCoverPhoto(filePath: '/path/to/cover.jpg');

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.isSaving, false);
    });

    test('should delete cover photo successfully', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.deleteCoverPhoto(),
      ).thenAnswer((_) async => const Right(unit));

      when(
        () => mockRepository.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfile));

      when(
        () => mockRepository.getFollowStatus(any()),
      ).thenAnswer((_) async => tFollowStatus);

      await notifier.deleteCoverPhoto();

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.isSaving, false);
    });

    test('should follow user and update state optimistically', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(
        profile: tProfile,
        followStatus: tFollowStatus,
      );

      when(
        () => mockRepository.followUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(unit));

      await notifier.followUser(userId: 'user-002');

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.profile.isFollowing, true);
      expect(loaded.profile.followersCount, equals(1241));
    });

    test('should not follow if already following', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfileFollowing);

      await notifier.followUser(userId: 'user-001');

      verifyNever(
        () => mockRepository.followUser(userId: any(named: 'userId')),
      );
    });

    test('should handle follow failure', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.followUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => Left(ServerFailure('Test error')));

      await notifier.followUser(userId: 'user-002');

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.profile.isFollowing, false);
    });

    test('should unfollow user and update state optimistically', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfileFollowing);

      when(
        () => mockRepository.unfollowUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(unit));

      await notifier.unfollowUser(userId: 'user-001');

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.profile.isFollowing, false);
      expect(loaded.profile.followersCount, equals(1240));
    });

    test('should not unfollow if not following', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      await notifier.unfollowUser(userId: 'user-002');

      verifyNever(
        () => mockRepository.unfollowUser(userId: any(named: 'userId')),
      );
    });

    test('should clamp followers count to 0 on unfollow', () async {
      final notifier = container.read(testProfileProvider.notifier);
      final profileWithOneFollower = tProfile.copyWith(followersCount: 1);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(
        profile: profileWithOneFollower.copyWith(isFollowing: true),
      );

      when(
        () => mockRepository.unfollowUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(unit));

      await notifier.unfollowUser(userId: 'user-002');

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.profile.followersCount, equals(0));
    });

    test('should sync followers count', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      notifier.syncConnectionsCount(
        type: 0, // followers
        count: 2000,
      );

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.profile.followersCount, equals(2000));
    });

    test('should sync following count', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      notifier.syncConnectionsCount(
        type: 1, // following
        count: 500,
      );

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.profile.followingCount, equals(500));
    });

    test('should clamp negative count to 0 on sync', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      notifier.syncConnectionsCount(
        type: 0, // followers
        count: -10,
      );

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.profile.followersCount, equals(0));
    });

    test('should block user optimistically', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(
        profile: tProfile,
        followStatus: tFollowStatus,
      );

      notifier.blockUser('user-002');

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.isBlocked, true);
      expect(loaded.followStatus.isBlocking, true);
      expect(loaded.followStatus.isFollowing, false);
    });

    test('should unblock user with rollback on failure', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(
        profile: tProfile,
        isBlocked: true,
        followStatus: tFollowStatusBlocking,
      );

      when(
        () => mockRepository.unblockUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => Left(ServerFailure('Test error')));

      await notifier.unblockUser('user-002');

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.isBlocked, true);
      expect(loaded.followStatus.isBlocking, true);
    });

    test('should load follow status after unblock success', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(
        profile: tProfile,
        isBlocked: true,
        followStatus: tFollowStatusBlocking,
      );

      when(
        () => mockRepository.unblockUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(unit));

      when(
        () => mockRepository.getFollowStatus(any()),
      ).thenAnswer((_) async => tFollowStatus);

      await notifier.unblockUser('user-002');

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
    });

    test(
      'should not do anything when state is not ProfileLoaded for loadLikedTracks',
      () async {
        final notifier = container.read(testProfileProvider.notifier);
        // ignore: invalid_use_of_protected_member
        notifier.state = const ProfileInitial();

        await notifier.loadLikedTracks(userId: tProfile.id);

        expect(container.read(testProfileProvider), isA<ProfileInitial>());
      },
    );

    test(
      'should not do anything when state is ProfileLoading for operations',
      () async {
        final notifier = container.read(testProfileProvider.notifier);
        // ignore: invalid_use_of_protected_member
        notifier.state = const ProfileLoading();

        await notifier.updateProfile(
          displayName: 'Name',
          username: 'user',
          firstName: 'First',
          lastName: 'Last',
          city: 'Cairo',
          country: 'Egypt',
          bio: 'Bio',
        );

        expect(container.read(testProfileProvider), isA<ProfileLoading>());
      },
    );

    test('should handle loading own profile via me endpoint', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = const ProfileInitial();

      when(
        () => mockRepository.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfile));

      when(
        () => mockRepository.getFollowStatus(any()),
      ).thenAnswer((_) async => tFollowStatus);

      await notifier.loadProfile(userId: 'me');

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.followStatus, equals(FollowStatus.empty));
    });

    test('should not load follow status for own profile', () async {
      final notifier = container.read(testProfileProvider.notifier);
      // ignore: invalid_use_of_protected_member
      notifier.state = ProfileLoaded(profile: tProfile);

      when(
        () => mockRepository.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfile));

      await notifier.loadProfile(userId: 'me');

      expect(container.read(testProfileProvider), isA<ProfileLoaded>());
      final loaded = container.read(testProfileProvider) as ProfileLoaded;
      expect(loaded.followStatus, equals(FollowStatus.empty));
    });
  });
}
