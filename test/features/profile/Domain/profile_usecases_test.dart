import 'package:dartz/dartz.dart';
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

// ---------------------------------------------------------------------------
// Mock
// ---------------------------------------------------------------------------

class MockProfileRepository extends Mock implements ProfileRepository {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const tProfile = ProfileEntity(
  id: 'user-001',
  displayName: 'KarimWI',
  username: 'karimwi',
  avatarUrl: 'https://i.pravatar.cc/400?img=11',
  coverUrl: 'https://picsum.photos/seed/karim/1500/500',
  city: 'Giza',
  country: 'EG',
  bio: 'Music producer from Egypt.',
  followersCount: 1240,
  followingCount: 380,
  tracksCount: 14,
  isFollowing: false,
  isVerified: false,
);

final tTrack = Track(
  id: 'track-001',
  userId: 'user-002',
  title: 'Cairo Nights',
  artist: 'Bassel Alaa',
  audioUrl: 'https://example.com/audio.mp3',
  duration: const Duration(seconds: 238),
  createdAt: DateTime(2024, 1, 1),
);

void main() {
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
  });

  // =========================================================================
  // GetProfileUseCase
  // =========================================================================

  group('GetProfileUseCase', () {
    late GetProfileUseCase useCase;

    setUp(() => useCase = GetProfileUseCase(mockRepository));

    test('should return ProfileEntity when userId is valid', () async {
      when(
        () => mockRepository.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(tProfile));

      final result = await useCase(userId: 'user-001');

      expect(result, const Right(tProfile));
      verify(() => mockRepository.getProfile(userId: 'user-001')).called(1);
    });

    test('should return ProfileEntity when userId is "me"', () async {
      when(
        () => mockRepository.getProfile(userId: 'me'),
      ).thenAnswer((_) async => const Right(tProfile));

      final result = await useCase(userId: 'me');

      expect(result, const Right(tProfile));
    });

    test('should return ServerFailure when profile is not found', () async {
      when(
        () => mockRepository.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Left(ServerFailure('PROFILE_NOT_FOUND')));

      final result = await useCase(userId: 'nonexistent');

      expect((result as Left).value, isA<ServerFailure>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(
        () => mockRepository.getProfile(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(userId: 'user-001');

      expect((result as Left).value, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // UpdateProfileUseCase
  // =========================================================================

  group('UpdateProfileUseCase', () {
    late UpdateProfileUseCase useCase;

    setUp(() => useCase = UpdateProfileUseCase(mockRepository));

    test('should return updated ProfileEntity when update succeeds', () async {
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

      final result = await useCase(
        displayName: 'KarimWI',
        username: 'karimwi',
        firstName: 'Karim',
        lastName: 'Wi',
        city: 'Giza',
        country: 'EG',
        bio: 'Music producer',
      );

      expect(result, const Right(tProfile));
    });

    test('should return ValidationFailure when displayName is empty', () async {
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
      ).thenAnswer(
        (_) async =>
            const Left(ValidationFailure('Display name cannot be empty')),
      );

      final result = await useCase(
        displayName: '',
        username: '',
        firstName: '',
        lastName: '',
        city: 'Giza',
        country: 'EG',
        bio: '',
      );

      expect((result as Left).value, isA<ValidationFailure>());
    });

    test('should pass all parameters to repository correctly', () async {
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

      await useCase(
        displayName: 'NewName',
        username: 'newname',
        firstName: 'New',
        lastName: 'Name',
        city: 'Cairo',
        country: 'EG',
        bio: 'New bio',
      );

      verify(
        () => mockRepository.updateProfile(
          displayName: 'NewName',
          username: 'newname',
          firstName: 'New',
          lastName: 'Name',
          city: 'Cairo',
          country: 'EG',
          bio: 'New bio',
        ),
      ).called(1);
    });

    test('should return NetworkFailure when there is no connection', () async {
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
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(
        displayName: 'KarimWI',
        username: 'karimwi',
        firstName: 'Karim',
        lastName: 'Wi',
        city: 'Giza',
        country: 'EG',
        bio: '',
      );

      expect((result as Left).value, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // UploadAvatarUseCase
  // =========================================================================

  group('UploadAvatarUseCase', () {
    late UploadAvatarUseCase useCase;

    setUp(() => useCase = UploadAvatarUseCase(mockRepository));

    test('should return updated ProfileEntity when upload succeeds', () async {
      when(
        () => mockRepository.uploadAvatar(filePath: any(named: 'filePath')),
      ).thenAnswer((_) async => const Right(tProfile));

      final result = await useCase(filePath: '/path/to/avatar.jpg');

      expect(result, const Right(tProfile));
      verify(
        () => mockRepository.uploadAvatar(filePath: '/path/to/avatar.jpg'),
      ).called(1);
    });

    test('should return ServerFailure when file is too large', () async {
      when(
        () => mockRepository.uploadAvatar(filePath: any(named: 'filePath')),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('UPLOAD_FILE_TOO_LARGE')),
      );

      final result = await useCase(filePath: '/path/to/large.jpg');

      expect((result as Left).value, isA<ServerFailure>());
    });

    test('should return ServerFailure when file type is invalid', () async {
      when(
        () => mockRepository.uploadAvatar(filePath: any(named: 'filePath')),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('UPLOAD_INVALID_FILE_TYPE')),
      );

      final result = await useCase(filePath: '/path/to/file.pdf');

      expect((result as Left).value, isA<ServerFailure>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(
        () => mockRepository.uploadAvatar(filePath: any(named: 'filePath')),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(filePath: '/path/to/avatar.jpg');

      expect((result as Left).value, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // DeleteAvatarUseCase
  // =========================================================================

  group('DeleteAvatarUseCase', () {
    late DeleteAvatarUseCase useCase;

    setUp(() => useCase = DeleteAvatarUseCase(mockRepository));

    test('should return Right(void) when deletion succeeds', () async {
      when(
        () => mockRepository.deleteAvatar(),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right(null));
      verify(() => mockRepository.deleteAvatar()).called(1);
    });

    test('should return Failure when deletion fails', () async {
      when(
        () => mockRepository.deleteAvatar(),
      ).thenAnswer((_) async => const Left(ServerFailure('Deletion failed')));

      final result = await useCase();

      expect(result, isA<Left>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(
        () => mockRepository.deleteAvatar(),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase();

      expect((result as Left).value, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // UploadCoverPhotoUseCase
  // =========================================================================

  group('UploadCoverPhotoUseCase', () {
    late UploadCoverPhotoUseCase useCase;

    setUp(() => useCase = UploadCoverPhotoUseCase(mockRepository));

    test('should return updated ProfileEntity when upload succeeds', () async {
      when(
        () => mockRepository.uploadCoverPhoto(filePath: any(named: 'filePath')),
      ).thenAnswer((_) async => const Right(tProfile));

      final result = await useCase(filePath: '/path/to/cover.jpg');

      expect(result, const Right(tProfile));
      verify(
        () => mockRepository.uploadCoverPhoto(filePath: '/path/to/cover.jpg'),
      ).called(1);
    });

    test('should return ServerFailure when file is too large', () async {
      when(
        () => mockRepository.uploadCoverPhoto(filePath: any(named: 'filePath')),
      ).thenAnswer(
        (_) async => const Left(ServerFailure('UPLOAD_FILE_TOO_LARGE')),
      );

      final result = await useCase(filePath: '/path/to/large.jpg');

      expect((result as Left).value, isA<ServerFailure>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(
        () => mockRepository.uploadCoverPhoto(filePath: any(named: 'filePath')),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(filePath: '/path/to/cover.jpg');

      expect((result as Left).value, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // DeleteCoverPhotoUseCase
  // =========================================================================

  group('DeleteCoverPhotoUseCase', () {
    late DeleteCoverPhotoUseCase useCase;

    setUp(() => useCase = DeleteCoverPhotoUseCase(mockRepository));

    test('should return Right(void) when deletion succeeds', () async {
      when(
        () => mockRepository.deleteCoverPhoto(),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase();

      expect(result, const Right(null));
      verify(() => mockRepository.deleteCoverPhoto()).called(1);
    });

    test('should return Failure when deletion fails', () async {
      when(
        () => mockRepository.deleteCoverPhoto(),
      ).thenAnswer((_) async => const Left(ServerFailure('Deletion failed')));

      final result = await useCase();

      expect(result, isA<Left>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(
        () => mockRepository.deleteCoverPhoto(),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase();

      expect((result as Left).value, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // GetFollowUserUseCase
  // =========================================================================

  group('GetFollowUserUseCase', () {
    late GetFollowUserUseCase useCase;

    setUp(() => useCase = GetFollowUserUseCase(mockRepository));

    test('should return Right(void) when follow succeeds', () async {
      when(
        () => mockRepository.followUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(userId: 'user-002');

      expect(result, const Right(null));
      verify(() => mockRepository.followUser(userId: 'user-002')).called(1);
    });

    test(
      'should return ServerFailure when user tries to follow themselves',
      () async {
        when(
          () => mockRepository.followUser(userId: any(named: 'userId')),
        ).thenAnswer((_) async => const Left(ServerFailure('FOLLOW_SELF')));

        final result = await useCase(userId: 'user-001');

        result.fold((failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message, contains('FOLLOW_SELF'));
        }, (_) => fail('Expected Left(ServerFailure), got Right'));
      },
    );

    test('should return NetworkFailure when there is no connection', () async {
      when(
        () => mockRepository.followUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(userId: 'user-002');

      expect((result as Left).value, isA<NetworkFailure>());
    });

    test('should pass userId directly to repository', () async {
      when(
        () => mockRepository.followUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(null));

      await useCase(userId: 'user-004');

      verify(() => mockRepository.followUser(userId: 'user-004')).called(1);
    });
  });

  // =========================================================================
  // GetUnfollowUserUseCase
  // =========================================================================

  group('GetUnfollowUserUseCase', () {
    late GetUnfollowUserUseCase useCase;

    setUp(() => useCase = GetUnfollowUserUseCase(mockRepository));

    test('should return Right(void) when unfollow succeeds', () async {
      when(
        () => mockRepository.unfollowUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(userId: 'user-002');

      expect(result, const Right(null));
      verify(() => mockRepository.unfollowUser(userId: 'user-002')).called(1);
    });

    test('should return Failure when unfollow fails', () async {
      when(
        () => mockRepository.unfollowUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Left(ServerFailure('Unfollow failed')));

      final result = await useCase(userId: 'user-002');

      expect(result, isA<Left>());
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(
        () => mockRepository.unfollowUser(userId: any(named: 'userId')),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(userId: 'user-002');

      expect((result as Left).value, isA<NetworkFailure>());
    });
  });

  // =========================================================================
  // GetLikedTracksUseCase
  // =========================================================================

  group('GetLikedTracksUseCase', () {
    late GetLikedTracksUseCase useCase;

    setUp(() => useCase = GetLikedTracksUseCase(mockRepository));

    test('should return list of tracks when fetch succeeds', () async {
      when(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right([tTrack]));

      final result = await useCase(userId: 'user-001', page: 1, limit: 20);

      expect(result, isA<Right>());
      expect((result as Right).value, [tTrack]);
    });

    test('should return empty list when there are no more pages', () async {
      when(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await useCase(userId: 'user-001', page: 99, limit: 20);

      expect((result as Right).value, isEmpty);
    });

    test('should use default page 1 and limit 20 when not specified', () async {
      when(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right([tTrack]));

      await useCase(userId: 'user-001');

      verify(
        () => mockRepository.getLikedTracks(
          userId: 'user-001',
          page: 1,
          limit: 20,
        ),
      ).called(1);
    });

    test('should work with userId "me" for own liked tracks', () async {
      when(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right([tTrack]));

      final result = await useCase(userId: 'me', page: 1, limit: 20);

      expect(result, isA<Right>());
      verify(
        () => mockRepository.getLikedTracks(userId: 'me', page: 1, limit: 20),
      ).called(1);
    });

    test('should return NetworkFailure when there is no connection', () async {
      when(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await useCase(userId: 'user-001', page: 1, limit: 20);

      expect((result as Left).value, isA<NetworkFailure>());
    });

    test('should return ServerFailure when profile is not found', () async {
      when(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Left(ServerFailure('PROFILE_NOT_FOUND')));

      final result = await useCase(userId: 'nonexistent', page: 1, limit: 20);

      expect((result as Left).value, isA<ServerFailure>());
    });

    test('should pass custom page and limit to repository', () async {
      when(
        () => mockRepository.getLikedTracks(
          userId: any(named: 'userId'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right([tTrack]));

      await useCase(userId: 'user-001', page: 3, limit: 10);

      verify(
        () => mockRepository.getLikedTracks(
          userId: 'user-001',
          page: 3,
          limit: 10,
        ),
      ).called(1);
    });
  });
}
