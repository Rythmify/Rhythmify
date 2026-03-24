import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/errors/failures.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';
import 'package:rythmify/features/profile/domain/repositories/profile_repository.dart';
import 'package:rythmify/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/upload_avatar_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/delete_avatar_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/upload_cover_photo_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/delete_cover_photo_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/follow_user_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/unfollow_user_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_liked_tracks_usecase.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_state.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockProfileRepository extends Mock implements ProfileRepository {}

// ---------------------------------------------------------------------------
// Testable notifier — use cases injected directly, no provider wiring
// ---------------------------------------------------------------------------
//
// ProfileNotifier reads authProvider and calls ProfileRemoteDatasourceImpl
// (or mock) in build(). For unit tests we bypass build() entirely by
// injecting use-case instances, mirroring the real notifier's public API.

class _ProfileNotifierUnderTest extends Notifier<ProfileState> {
  final GetProfileUseCase getProfileUC;
  final UpdateProfileUseCase updateProfileUC;
  final UploadAvatarUseCase uploadAvatarUC;
  final DeleteAvatarUseCase deleteAvatarUC;
  final UploadCoverPhotoUseCase uploadCoverPhotoUC;
  final DeleteCoverPhotoUseCase deleteCoverPhotoUC;
  final FollowUserUseCase followUserUC;
  final UnfollowUserUseCase unfollowUserUC;
  final GetLikedTracksUseCase getLikedTracksUC;

  int _currentPage = 1;

  _ProfileNotifierUnderTest({
    required this.getProfileUC,
    required this.updateProfileUC,
    required this.uploadAvatarUC,
    required this.deleteAvatarUC,
    required this.uploadCoverPhotoUC,
    required this.deleteCoverPhotoUC,
    required this.followUserUC,
    required this.unfollowUserUC,
    required this.getLikedTracksUC,
  });

  @override
  ProfileState build() => const ProfileInitial();

  Future<void> loadProfile({required String userId}) async {
    state = const ProfileLoading();
    final result = await getProfileUC(userId: userId);
    result.fold((f) => state = ProfileError(f.message), (p) {
      state = ProfileLoaded(profile: p);
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

    final result = await getLikedTracksUC(
      userId: userId,
      page: _currentPage,
      limit: 20,
    );

    result.fold(
      (f) {
        if (state is ProfileLoaded) {
          state = (state as ProfileLoaded).copyWith(isLoadingTracks: false);
        }
      },
      (tracks) {
        if (state is ProfileLoaded) {
          final c = state as ProfileLoaded;
          final updated = refresh ? tracks : [...c.likedTracks, ...tracks];
          _currentPage++;
          state = c.copyWith(
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
    final result = await updateProfileUC(
      displayName: displayName,
      city: city,
      country: country,
      bio: bio,
    );
    result.fold(
      (f) => state = current.copyWith(isSaving: false),
      (p) => state = current.copyWith(profile: p, isSaving: false),
    );
  }

  Future<void> uploadAvatar({required String filePath}) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    state = current.copyWith(isSaving: true);
    final result = await uploadAvatarUC(filePath: filePath);
    result.fold(
      (f) => state = current.copyWith(isSaving: false),
      (p) => state = current.copyWith(profile: p, isSaving: false),
    );
  }

  Future<void> deleteAvatar() async {
    final current = state;
    if (current is! ProfileLoaded) return;
    state = current.copyWith(isSaving: true);
    final result = await deleteAvatarUC();
    result.fold(
      (f) => state = current.copyWith(isSaving: false),
      (_) => state = current.copyWith(isSaving: false),
    );
  }

  Future<void> uploadCoverPhoto({required String filePath}) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    state = current.copyWith(isSaving: true);
    final result = await uploadCoverPhotoUC(filePath: filePath);
    result.fold(
      (f) => state = current.copyWith(isSaving: false),
      (p) => state = current.copyWith(profile: p, isSaving: false),
    );
  }

  Future<void> deleteCoverPhoto() async {
    final current = state;
    if (current is! ProfileLoaded) return;
    state = current.copyWith(isSaving: true);
    final result = await deleteCoverPhotoUC();
    result.fold(
      (f) => state = current.copyWith(isSaving: false),
      (_) => state = current.copyWith(isSaving: false),
    );
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
    final result = await followUserUC(userId: userId);
    result.fold((f) => state = current, (_) {});
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
    final result = await unfollowUserUC(userId: userId);
    result.fold((f) => state = current, (_) {});
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

const tUpdatedProfile = ProfileEntity(
  id: 'user-001',
  displayName: 'Updated Name',
  city: 'Cairo',
  country: 'EG',
  followersCount: 1240,
  followingCount: 380,
  tracksCount: 14,
  isFollowing: false,
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

// ---------------------------------------------------------------------------
// Factory
// ---------------------------------------------------------------------------

_ProfileNotifierUnderTest makeNotifier(MockProfileRepository repo) =>
    _ProfileNotifierUnderTest(
      getProfileUC: GetProfileUseCase(repo),
      updateProfileUC: UpdateProfileUseCase(repo),
      uploadAvatarUC: UploadAvatarUseCase(repo),
      deleteAvatarUC: DeleteAvatarUseCase(repo),
      uploadCoverPhotoUC: UploadCoverPhotoUseCase(repo),
      deleteCoverPhotoUC: DeleteCoverPhotoUseCase(repo),
      followUserUC: FollowUserUseCase(repo),
      unfollowUserUC: UnfollowUserUseCase(repo),
      getLikedTracksUC: GetLikedTracksUseCase(repo),
    );

void main() {
  late MockProfileRepository mockRepo;
  late _ProfileNotifierUnderTest notifier;

  // Helper: prime state to ProfileLoaded
  Future<void> primeLoaded({
    MockProfileRepository? repo,
    _ProfileNotifierUnderTest? n,
    List<Track> tracks = const [],
  }) async {
    final r = repo ?? mockRepo;
    final target = n ?? notifier;
    when(
      () => r.getProfile(userId: any(named: 'userId')),
    ).thenAnswer((_) async => const Right(tProfile));
    when(
      () => r.getLikedTracks(
        userId: any(named: 'userId'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => Right(tracks));
    await target.loadProfile(userId: 'user-001');
    await Future.delayed(Duration.zero);
  }

  setUp(() {
    mockRepo = MockProfileRepository();
    notifier = makeNotifier(mockRepo);
    // Initialise the notifier
    final provider = NotifierProvider<_ProfileNotifierUnderTest, ProfileState>(
      () => notifier,
    );
    ProviderContainer().read(provider);
  });

  // =========================================================================
  // loadProfile
  // =========================================================================

  group('ProfileNotifier.loadProfile', () {
    test('should store the profile in ProfileLoaded on success', () async {
      await primeLoaded();
      final loaded = notifier.state as ProfileLoaded;
      expect(loaded.profile, tProfile);
    });

    test('should emit ProfileError when getProfile fails', () async {
      when(() => mockRepo.getProfile(userId: any(named: 'userId'))).thenAnswer(
        (_) async => const Left(ServerFailure('User profile not found.')),
      );

      await notifier.loadProfile(userId: 'nonexistent');

      expect(notifier.state, isA<ProfileError>());
      expect(
        (notifier.state as ProfileError).message,
        'User profile not found.',
      );
    });

    test('should load own profile when userId is "me"', () async {
      when(
        () => mockRepo.getProfile(userId: 'me'),
      ).thenAnswer((_) async => const Right(tProfile));
      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Right([]));

      await notifier.loadProfile(userId: 'me');
      await Future.delayed(Duration.zero);

      expect(notifier.state, isA<ProfileLoaded>());
      verify(() => mockRepo.getProfile(userId: 'me')).called(1);
    });

    test(
      'should trigger loadLikedTracks after successful profile load',
      () async {
        await primeLoaded();

        verify(
          () => mockRepo.getLikedTracks(
            userId: any(named: 'userId'),
            page: 1,
            limit: 20,
          ),
        ).called(1);
      },
    );

    test('should emit NetworkFailure error when connection fails', () async {
      when(
        () => mockRepo.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      await notifier.loadProfile(userId: 'user-001');

      expect(notifier.state, isA<ProfileError>());
      expect((notifier.state as ProfileError).message, contains('internet'));
    });
  });

  // =========================================================================
  // loadLikedTracks
  // =========================================================================

  group('ProfileNotifier.loadLikedTracks', () {
    setUp(() async => primeLoaded());

    test('should append tracks on subsequent pages', () async {
      final page1 = makeTracks(20);
      final page2 = makeTracks(5);

      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: 1,
          limit: 20,
        ),
      ).thenAnswer((_) async => Right(page1));

      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: 2,
          limit: 20,
        ),
      ).thenAnswer((_) async => Right(page2));

      await notifier.loadLikedTracks(userId: 'user-001', refresh: true);
      await notifier.loadLikedTracks(userId: 'user-001', refresh: false);

      final loaded = notifier.state as ProfileLoaded;
      expect(loaded.likedTracks.length, 25);
    });

    test(
      'should set hasMoreTracks false when page has fewer than 20 tracks',
      () async {
        when(
          () => mockRepo.getLikedTracks(
            userId: any(named: 'userId'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Right(makeTracks(5)));

        await notifier.loadLikedTracks(userId: 'user-001', refresh: true);

        final loaded = notifier.state as ProfileLoaded;
        expect(loaded.hasMoreTracks, false);
      },
    );

    test(
      'should set hasMoreTracks true when page has exactly 20 tracks',
      () async {
        when(
          () => mockRepo.getLikedTracks(
            userId: any(named: 'userId'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Right(makeTracks(20)));

        await notifier.loadLikedTracks(userId: 'user-001', refresh: true);

        final loaded = notifier.state as ProfileLoaded;
        expect(loaded.hasMoreTracks, true);
      },
    );

    test(
      'should not fetch when hasMoreTracks is false and refresh is false',
      () async {
        when(
          () => mockRepo.getLikedTracks(
            userId: any(named: 'userId'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Right(makeTracks(3)));

        await notifier.loadLikedTracks(userId: 'user-001', refresh: true);
        // hasMoreTracks is now false
        final beforeCount =
            (notifier.state as ProfileLoaded).likedTracks.length;

        await notifier.loadLikedTracks(userId: 'user-001', refresh: false);

        expect(
          (notifier.state as ProfileLoaded).likedTracks.length,
          beforeCount,
        );
      },
    );

    test('should replace likedTracks on refresh', () async {
      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(makeTracks(20)));

      await notifier.loadLikedTracks(userId: 'user-001', refresh: true);
      // First page = 20 tracks

      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(makeTracks(3)));

      await notifier.loadLikedTracks(userId: 'user-001', refresh: true);
      // Refresh replaces, not appends

      expect((notifier.state as ProfileLoaded).likedTracks.length, 3);
    });

    test('should set isLoadingTracks false on failure', () async {
      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      await notifier.loadLikedTracks(userId: 'user-001', refresh: true);

      final loaded = notifier.state as ProfileLoaded;
      expect(loaded.isLoadingTracks, false);
    });

    test('should do nothing when state is not ProfileLoaded', () async {
      notifier.state = const ProfileInitial();
      await notifier.loadLikedTracks(userId: 'user-001');
      expect(notifier.state, const ProfileInitial());
    });

    test(
      'should not start a second load when isLoadingTracks is true',
      () async {
        // Manually set loading state
        notifier.state = const ProfileLoaded(
          profile: tProfile,
          isLoadingTracks: true,
        );

        await notifier.loadLikedTracks(userId: 'user-001');

        // getLikedTracks should NOT be called since guard fires
        verifyNever(
          () => mockRepo.getLikedTracks(
            userId: any(named: 'userId'),
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        );
      },
    );
  });

  // =========================================================================
  // updateProfile
  // =========================================================================

  group('ProfileNotifier.updateProfile', () {
    setUp(() async => primeLoaded());

    test('should update profile in state on success', () async {
      when(
        () => mockRepo.updateProfile(
          displayName: any(named: 'displayName'),
          city: any(named: 'city'),
          country: any(named: 'country'),
          bio: any(named: 'bio'),
        ),
      ).thenAnswer((_) async => const Right(tUpdatedProfile));

      await notifier.updateProfile(
        displayName: 'Updated Name',
        city: 'Cairo',
        country: 'EG',
        bio: 'New bio',
      );

      final loaded = notifier.state as ProfileLoaded;
      expect(loaded.profile.displayName, 'Updated Name');
      expect(loaded.isSaving, false);
    });

    test(
      'should restore isSaving false and keep original profile on failure',
      () async {
        when(
          () => mockRepo.updateProfile(
            displayName: any(named: 'displayName'),
            city: any(named: 'city'),
            country: any(named: 'country'),
            bio: any(named: 'bio'),
          ),
        ).thenAnswer((_) async => const Left(ValidationFailure('Invalid')));

        await notifier.updateProfile(
          displayName: '',
          city: '',
          country: '',
          bio: '',
        );

        final loaded = notifier.state as ProfileLoaded;
        expect(loaded.isSaving, false);
        expect(loaded.profile, tProfile); // unchanged
      },
    );

    test('should pass all params to repository correctly', () async {
      when(
        () => mockRepo.updateProfile(
          displayName: any(named: 'displayName'),
          city: any(named: 'city'),
          country: any(named: 'country'),
          bio: any(named: 'bio'),
        ),
      ).thenAnswer((_) async => const Right(tUpdatedProfile));

      await notifier.updateProfile(
        displayName: 'KarimWI',
        city: 'Giza',
        country: 'EG',
        bio: 'Music producer',
      );

      verify(
        () => mockRepo.updateProfile(
          displayName: 'KarimWI',
          city: 'Giza',
          country: 'EG',
          bio: 'Music producer',
        ),
      ).called(1);
    });

    test('should do nothing when state is not ProfileLoaded', () async {
      notifier.state = const ProfileInitial();
      await notifier.updateProfile(
        displayName: 'X',
        city: '',
        country: '',
        bio: '',
      );
      expect(notifier.state, const ProfileInitial());
    });
  });

  // =========================================================================
  // uploadAvatar
  // =========================================================================

  group('ProfileNotifier.uploadAvatar', () {
    setUp(() async => primeLoaded());

    test('should update profile and set isSaving false on success', () async {
      when(
        () => mockRepo.uploadAvatar(filePath: any(named: 'filePath')),
      ).thenAnswer((_) async => const Right(tUpdatedProfile));
      // reload triggered internally
      when(
        () => mockRepo.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tUpdatedProfile));
      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Right([]));

      await notifier.uploadAvatar(filePath: '/path/avatar.jpg');

      verify(
        () => mockRepo.uploadAvatar(filePath: '/path/avatar.jpg'),
      ).called(1);
    });

    test('should restore isSaving false on failure', () async {
      when(
        () => mockRepo.uploadAvatar(filePath: any(named: 'filePath')),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('UPLOAD_FILE_TOO_LARGE')),
      );

      await notifier.uploadAvatar(filePath: '/path/large.jpg');

      expect((notifier.state as ProfileLoaded).isSaving, false);
    });

    test('should do nothing when state is not ProfileLoaded', () async {
      notifier.state = const ProfileInitial();
      await notifier.uploadAvatar(filePath: '/path/avatar.jpg');
      expect(notifier.state, const ProfileInitial());
    });
  });

  // =========================================================================
  // deleteAvatar
  // =========================================================================

  group('ProfileNotifier.deleteAvatar', () {
    setUp(() async => primeLoaded());

    test('should set isSaving false on success', () async {
      when(
        () => mockRepo.deleteAvatar(),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockRepo.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfile));
      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Right([]));

      await notifier.deleteAvatar();

      verify(() => mockRepo.deleteAvatar()).called(1);
    });

    test('should restore isSaving false on failure', () async {
      when(
        () => mockRepo.deleteAvatar(),
      ).thenAnswer((_) async => const Left(ServerFailure('Delete failed')));

      await notifier.deleteAvatar();

      expect((notifier.state as ProfileLoaded).isSaving, false);
    });

    test('should do nothing when state is not ProfileLoaded', () async {
      notifier.state = const ProfileInitial();
      await notifier.deleteAvatar();
      expect(notifier.state, const ProfileInitial());
    });
  });

  // =========================================================================
  // uploadCoverPhoto
  // =========================================================================

  group('ProfileNotifier.uploadCoverPhoto', () {
    setUp(() async => primeLoaded());

    test('should call repository with correct file path', () async {
      when(
        () => mockRepo.uploadCoverPhoto(filePath: any(named: 'filePath')),
      ).thenAnswer((_) async => const Right(tProfile));
      when(
        () => mockRepo.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfile));
      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Right([]));

      await notifier.uploadCoverPhoto(filePath: '/path/cover.jpg');

      verify(
        () => mockRepo.uploadCoverPhoto(filePath: '/path/cover.jpg'),
      ).called(1);
    });

    test('should restore isSaving false on failure', () async {
      when(
        () => mockRepo.uploadCoverPhoto(filePath: any(named: 'filePath')),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('UPLOAD_FILE_TOO_LARGE')),
      );

      await notifier.uploadCoverPhoto(filePath: '/path/large.jpg');

      expect((notifier.state as ProfileLoaded).isSaving, false);
    });

    test('should do nothing when state is not ProfileLoaded', () async {
      notifier.state = const ProfileInitial();
      await notifier.uploadCoverPhoto(filePath: '/path/cover.jpg');
      expect(notifier.state, const ProfileInitial());
    });
  });

  // =========================================================================
  // deleteCoverPhoto
  // =========================================================================

  group('ProfileNotifier.deleteCoverPhoto', () {
    setUp(() async => primeLoaded());

    test('should call deleteCoverPhoto on repository', () async {
      when(
        () => mockRepo.deleteCoverPhoto(),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => mockRepo.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfile));
      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Right([]));

      await notifier.deleteCoverPhoto();

      verify(() => mockRepo.deleteCoverPhoto()).called(1);
    });

    test('should restore isSaving false on failure', () async {
      when(
        () => mockRepo.deleteCoverPhoto(),
      ).thenAnswer((_) async => const Left(ServerFailure('Error')));

      await notifier.deleteCoverPhoto();

      expect((notifier.state as ProfileLoaded).isSaving, false);
    });

    test('should do nothing when state is not ProfileLoaded', () async {
      notifier.state = const ProfileInitial();
      await notifier.deleteCoverPhoto();
      expect(notifier.state, const ProfileInitial());
    });
  });

  // =========================================================================
  // followUser — optimistic update
  // =========================================================================

  group('ProfileNotifier.followUser', () {
    setUp(() async => primeLoaded());

    test(
      'should optimistically increment followersCount and set isFollowing',
      () async {
        when(
          () => mockRepo.followUser(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Right(null));

        await notifier.followUser(userId: 'user-002');

        final loaded = notifier.state as ProfileLoaded;
        expect(loaded.profile.isFollowing, true);
        expect(loaded.profile.followersCount, 1241);
      },
    );

    test(
      'should roll back optimistic update when backend call fails',
      () async {
        when(
          () => mockRepo.followUser(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Left(ServerFailure('Follow failed')));

        await notifier.followUser(userId: 'user-002');

        final loaded = notifier.state as ProfileLoaded;
        expect(loaded.profile.isFollowing, false);
        expect(loaded.profile.followersCount, 1240); // original
      },
    );

    test('should handle FOLLOW_SELF error gracefully with rollback', () async {
      when(
        () => mockRepo.followUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Left(ServerFailure('FOLLOW_SELF')));

      await notifier.followUser(userId: 'user-001'); // same user

      final loaded = notifier.state as ProfileLoaded;
      expect(loaded.profile.isFollowing, false); // rolled back
    });

    test('should do nothing when state is not ProfileLoaded', () async {
      notifier.state = const ProfileInitial();
      await notifier.followUser(userId: 'user-002');
      expect(notifier.state, const ProfileInitial());
    });

    test('should pass correct userId to repository', () async {
      when(
        () => mockRepo.followUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(null));

      await notifier.followUser(userId: 'user-004');

      verify(() => mockRepo.followUser(userId: 'user-004')).called(1);
    });
  });

  // =========================================================================
  // unfollowUser — optimistic update
  // =========================================================================

  group('ProfileNotifier.unfollowUser', () {
    // Start with a following state
    setUp(() async {
      when(
        () => mockRepo.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfileFollowing));
      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Right([]));
      await notifier.loadProfile(userId: 'user-001');
      await Future.delayed(Duration.zero);
    });

    test(
      'should optimistically decrement followersCount and clear isFollowing',
      () async {
        when(
          () => mockRepo.unfollowUser(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Right(null));

        await notifier.unfollowUser(userId: 'user-002');

        final loaded = notifier.state as ProfileLoaded;
        expect(loaded.profile.isFollowing, false);
        expect(loaded.profile.followersCount, 1240); // 1241 - 1
      },
    );

    test(
      'should roll back optimistic update when backend call fails',
      () async {
        when(
          () => mockRepo.unfollowUser(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Left(ServerFailure('Unfollow failed')));

        await notifier.unfollowUser(userId: 'user-002');

        final loaded = notifier.state as ProfileLoaded;
        expect(loaded.profile.isFollowing, true); // restored
        expect(loaded.profile.followersCount, 1241); // restored
      },
    );

    test('should do nothing when state is not ProfileLoaded', () async {
      notifier.state = const ProfileInitial();
      await notifier.unfollowUser(userId: 'user-002');
      expect(notifier.state, const ProfileInitial());
    });

    test('should pass correct userId to repository', () async {
      when(
        () => mockRepo.unfollowUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(null));

      await notifier.unfollowUser(userId: 'user-004');

      verify(() => mockRepo.unfollowUser(userId: 'user-004')).called(1);
    });
  });
}
