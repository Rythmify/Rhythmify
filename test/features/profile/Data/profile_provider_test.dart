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
import 'package:rythmify/features/profile/domain/usecases/get_follow_user_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_unfollow_user_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_liked_tracks_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_uploaded_tracks_usecase.dart';
import 'package:rythmify/features/profile/domain/usecases/get_reposted_tracks_usecase.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_state.dart';

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockProfileRepository extends Mock implements ProfileRepository {}

// ---------------------------------------------------------------------------
// Testable notifier
// ---------------------------------------------------------------------------

class _ProfileNotifierUnderTest extends Notifier<ProfileState> {
  final GetProfileUseCase getProfileUC;
  final UpdateProfileUseCase updateProfileUC;
  final UploadAvatarUseCase uploadAvatarUC;
  final DeleteAvatarUseCase deleteAvatarUC;
  final UploadCoverPhotoUseCase uploadCoverPhotoUC;
  final DeleteCoverPhotoUseCase deleteCoverPhotoUC;
  final GetFollowUserUseCase followUserUC;
  final GetUnfollowUserUseCase unfollowUserUC;
  final GetLikedTracksUseCase getLikedTracksUC;
  final GetUploadedTracksUseCase getUploadedTracksUC;
  final GetRepostedTracksUseCase getRepostedTracksUC;

  int _likesPage = 1;

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
    required this.getUploadedTracksUC,
    required this.getRepostedTracksUC,
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
    if (current.isLoadingLikes) return;

    if (refresh) {
      _likesPage = 1;
      state = current.copyWith(
        likedTracks: [],
        isLoadingLikes: true,
        hasMoreLikes: true,
      );
    } else {
      if (!current.hasMoreLikes) return;
      state = current.copyWith(isLoadingLikes: true);
    }

    final result = await getLikedTracksUC(
      userId: userId,
      page: _likesPage,
      limit: 20,
    );

    result.fold(
      (f) {
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
            hasMoreLikes: tracks.length == 20,
          );
        }
      },
    );
  }

  Future<void> updateProfile({
    required String displayName,
    required String username,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String bio,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;
    state = current.copyWith(isSaving: true);
    final result = await updateProfileUC(
      displayName: displayName,
      username: username,
      firstName: firstName,
      lastName: lastName,
      city: city,
      country: country,
      bio: bio,
    );
    result.fold(
      (f) => state = current.copyWith(isSaving: false),
      (p) => state = current.copyWith(profile: p, isSaving: false),
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

void main() {
  late MockProfileRepository mockRepo;
  late _ProfileNotifierUnderTest notifier;

  setUp(() {
    mockRepo = MockProfileRepository();
    notifier = _ProfileNotifierUnderTest(
      getProfileUC: GetProfileUseCase(mockRepo),
      updateProfileUC: UpdateProfileUseCase(mockRepo),
      uploadAvatarUC: UploadAvatarUseCase(mockRepo),
      deleteAvatarUC: DeleteAvatarUseCase(mockRepo),
      uploadCoverPhotoUC: UploadCoverPhotoUseCase(mockRepo),
      deleteCoverPhotoUC: DeleteCoverPhotoUseCase(mockRepo),
      followUserUC: GetFollowUserUseCase(mockRepo),
      unfollowUserUC: GetUnfollowUserUseCase(mockRepo),
      getLikedTracksUC: GetLikedTracksUseCase(mockRepo),
      getUploadedTracksUC: GetUploadedTracksUseCase(mockRepo),
      getRepostedTracksUC: GetRepostedTracksUseCase(mockRepo),
    );
  });

  group('ProfileNotifier', () {
    test('should set isLoadingLikes false on failure', () async {
      when(
        () => mockRepo.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfile));
      when(
        () => mockRepo.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      await notifier.loadProfile(userId: 'user-001');

      final loaded = notifier.state as ProfileLoaded;
      expect(loaded.isLoadingLikes, false);
    });

    test(
      'should not start a second load when isLoadingLikes is true',
      () async {
        notifier.state = const ProfileLoaded(
          profile: tProfile,
          isLoadingLikes: true,
        );

        await notifier.loadLikedTracks(userId: 'user-001');

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
}
