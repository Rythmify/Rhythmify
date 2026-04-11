import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/profile/data/datasources/profile_mock_datasource.dart';

void main() {
  late ProfileMockDatasource datasource;

  setUp(() {
    datasource = ProfileMockDatasource();
    ProfileMockDatasource.setCurrentUser('user-001');
  });

  test(
    'getProfile returns current user for me and throws for unknown user',
    () async {
      final me = await datasource.getProfile(userId: 'me');
      expect(me.id, 'user-001');

      expect(
        () => datasource.getProfile(userId: 'unknown-id'),
        throwsException,
      );
    },
  );

  test('updateProfile updates persisted current user', () async {
    final updated = await datasource.updateProfile(
      displayName: 'Updated',
      username: 'updated_user',
      firstName: 'Updated',
      lastName: 'User',
      city: 'Cairo',
      country: 'EG',
      bio: 'Bio',
    );

    expect(updated.displayName, 'Updated');

    final me = await datasource.getProfile(userId: 'me');
    expect(me.displayName, 'Updated');
  });

  test('updateProfile validates empty display name', () async {
    expect(
      () => datasource.updateProfile(
        displayName: '  ',
        username: 'user',
        firstName: 'First',
        lastName: 'Last',
        city: 'Cairo',
        country: 'EG',
        bio: 'Bio',
      ),
      throwsA(predicate((e) => e.toString().contains('VALIDATION_FAILED'))),
    );
  });

  test('avatar and cover mutations are reflected in profile', () async {
    final withAvatar = await datasource.uploadAvatar(filePath: 'avatar.png');
    expect(withAvatar.avatarUrl, isNotNull);

    await datasource.deleteAvatar();
    final afterDeleteAvatar = await datasource.getProfile(userId: 'me');
    expect(afterDeleteAvatar.avatarUrl, isNull);

    final withCover = await datasource.uploadCoverPhoto(filePath: 'cover.png');
    expect(withCover.coverUrl, isNotNull);

    await datasource.deleteCoverPhoto();
    final afterDeleteCover = await datasource.getProfile(userId: 'me');
    expect(afterDeleteCover.coverUrl, isNull);
  });

  test('followUser throws FOLLOW_SELF for self id', () async {
    expect(
      () => datasource.followUser(userId: 'user-001'),
      throwsA(predicate((e) => e.toString().contains('FOLLOW_SELF'))),
    );
  });

  test('followUser and unfollowUser succeed for other users', () async {
    await datasource.followUser(userId: 'user-002');
    await datasource.unfollowUser(userId: 'user-002');
  });

  test('getLikedTracks paginates and resolves me alias', () async {
    final page1 = await datasource.getLikedTracks(
      userId: 'me',
      page: 1,
      limit: 2,
    );
    final page2 = await datasource.getLikedTracks(
      userId: 'me',
      page: 2,
      limit: 2,
    );
    final page99 = await datasource.getLikedTracks(
      userId: 'me',
      page: 99,
      limit: 2,
    );

    expect(page1.length, 2);
    expect(page2.length, 2);
    expect(page99, isEmpty);
  });

  test('addDynamicProfile creates profile and empty likes list', () async {
    ProfileMockDatasource.addDynamicProfile(
      id: 'user-new',
      displayName: 'New User',
      email: 'new@test.com',
      gender: 'male',
      dateOfBirth: '2000-01-01',
    );

    final profile = await datasource.getProfile(userId: 'user-new');
    final likes = await datasource.getLikedTracks(
      userId: 'user-new',
      page: 1,
      limit: 20,
    );

    expect(profile.id, 'user-new');
    expect(profile.displayName, 'New User');
    expect(likes, isEmpty);
  });
}
