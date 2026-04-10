import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/errors/failures.dart';
import 'package:rythmify/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:rythmify/features/profile/data/models/profile_model.dart';
import 'package:rythmify/features/profile/data/models/track_model.dart';
import 'package:rythmify/features/profile/data/repositories/profile_repository_impl.dart';

class MockProfileRemoteDatasource extends Mock
    implements ProfileRemoteDatasource {}

void main() {
  late MockProfileRemoteDatasource datasource;
  late ProfileRepositoryImpl repository;

  const profile = ProfileModel(
    id: 'u1',
    displayName: 'User',
    followersCount: 1,
    followingCount: 2,
    tracksCount: 3,
    isFollowing: false,
  );

  final track = TrackModel.fromJson({
    'id': 't1',
    'user_id': 'u1',
    'title': 'T',
    'artist': 'A',
    'audio_url': 'url',
    'duration': 100,
    'created_at': '2026-01-01T00:00:00.000Z',
  });

  setUp(() {
    datasource = MockProfileRemoteDatasource();
    repository = ProfileRepositoryImpl(remoteDatasource: datasource);
  });

  test('returns Right for successful operations', () async {
    when(
      () => datasource.getProfile(userId: 'u1'),
    ).thenAnswer((_) async => profile);
    when(
      () => datasource.updateProfile(
        displayName: 'N',
        city: 'C',
        country: 'EG',
        bio: 'B',
      ),
    ).thenAnswer((_) async => profile);
    when(
      () => datasource.uploadAvatar(filePath: 'a.png'),
    ).thenAnswer((_) async => profile);
    when(() => datasource.deleteAvatar()).thenAnswer((_) async {});
    when(
      () => datasource.uploadCoverPhoto(filePath: 'c.png'),
    ).thenAnswer((_) async => profile);
    when(() => datasource.deleteCoverPhoto()).thenAnswer((_) async {});
    when(() => datasource.followUser(userId: 'u2')).thenAnswer((_) async {});
    when(() => datasource.unfollowUser(userId: 'u2')).thenAnswer((_) async {});
    when(
      () => datasource.getLikedTracks(userId: 'u1', page: 1, limit: 20),
    ).thenAnswer((_) async => [track]);

    expect((await repository.getProfile(userId: 'u1')).isRight(), true);
    expect(
      (await repository.updateProfile(
        displayName: 'N',
        city: 'C',
        country: 'EG',
        bio: 'B',
      )).isRight(),
      true,
    );
    expect((await repository.uploadAvatar(filePath: 'a.png')).isRight(), true);
    expect((await repository.deleteAvatar()).isRight(), true);
    expect(
      (await repository.uploadCoverPhoto(filePath: 'c.png')).isRight(),
      true,
    );
    expect((await repository.deleteCoverPhoto()).isRight(), true);
    expect((await repository.followUser(userId: 'u2')).isRight(), true);
    expect((await repository.unfollowUser(userId: 'u2')).isRight(), true);
    expect(
      (await repository.getLikedTracks(
        userId: 'u1',
        page: 1,
        limit: 20,
      )).isRight(),
      true,
    );
  });

  test('maps known profile errors', () async {
    when(
      () => datasource.getProfile(userId: 'u1'),
    ).thenThrow(Exception('PROFILE_NOT_FOUND'));
    when(
      () => datasource.updateProfile(
        displayName: 'N',
        city: 'C',
        country: 'EG',
        bio: 'B',
      ),
    ).thenThrow(Exception('UPLOAD_FILE_TOO_LARGE'));
    when(
      () => datasource.uploadAvatar(filePath: 'a.png'),
    ).thenThrow(Exception('UPLOAD_INVALID_FILE_TYPE'));
    when(() => datasource.deleteAvatar()).thenThrow(Exception('FOLLOW_SELF'));
    when(
      () => datasource.uploadCoverPhoto(filePath: 'c.png'),
    ).thenThrow(Exception('PERMISSION_DENIED'));
    when(
      () => datasource.deleteCoverPhoto(),
    ).thenThrow(Exception('VALIDATION_FAILED'));
    when(
      () => datasource.followUser(userId: 'u2'),
    ).thenThrow(Exception('RATE_LIMIT_EXCEEDED'));
    when(
      () => datasource.unfollowUser(userId: 'u2'),
    ).thenThrow(Exception('socket timeout'));

    expect(
      (await repository.getProfile(userId: 'u1')).fold((l) => l, (_) => null),
      isA<ServerFailure>(),
    );
    expect(
      (await repository.updateProfile(
        displayName: 'N',
        city: 'C',
        country: 'EG',
        bio: 'B',
      )).fold((l) => l, (_) => null),
      isA<ServerFailure>(),
    );
    expect(
      (await repository.uploadAvatar(
        filePath: 'a.png',
      )).fold((l) => l, (_) => null),
      isA<ServerFailure>(),
    );
    expect(
      (await repository.deleteAvatar()).fold((l) => l, (_) => null),
      isA<ServerFailure>(),
    );
    expect(
      (await repository.uploadCoverPhoto(
        filePath: 'c.png',
      )).fold((l) => l, (_) => null),
      isA<ServerFailure>(),
    );
    expect(
      (await repository.deleteCoverPhoto()).fold((l) => l, (_) => null),
      isA<ServerFailure>(),
    );
    expect(
      (await repository.followUser(userId: 'u2')).fold((l) => l, (_) => null),
      isA<TooManyRequestsFailure>(),
    );
    expect(
      (await repository.unfollowUser(userId: 'u2')).fold((l) => l, (_) => null),
      isA<NetworkFailure>(),
    );
  });
}
