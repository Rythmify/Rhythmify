import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Test fixtures
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

  const tProfileMinimal = ProfileEntity(
    id: 'user-002',
    displayName: 'Bassel Alaa',
    followersCount: 0,
    followingCount: 0,
    tracksCount: 0,
    isFollowing: false,
  );

  // ---------------------------------------------------------------------------
  // Construction
  // ---------------------------------------------------------------------------

  group('ProfileEntity — construction', () {
    test('should create a ProfileEntity with all fields set', () {
      expect(tProfile.id, 'user-001');
      expect(tProfile.displayName, 'KarimWI');
      expect(tProfile.username, 'karimwi');
      expect(tProfile.avatarUrl, 'https://i.pravatar.cc/400?img=11');
      expect(tProfile.coverUrl, 'https://picsum.photos/seed/karim/1500/500');
      expect(tProfile.city, 'Giza');
      expect(tProfile.country, 'EG');
      expect(tProfile.bio, 'Music producer from Egypt.');
      expect(tProfile.followersCount, 1240);
      expect(tProfile.followingCount, 380);
      expect(tProfile.tracksCount, 14);
      expect(tProfile.isFollowing, false);
      expect(tProfile.isVerified, false);
    });

    test('should default optional fields to null', () {
      expect(tProfileMinimal.username, isNull);
      expect(tProfileMinimal.avatarUrl, isNull);
      expect(tProfileMinimal.coverUrl, isNull);
      expect(tProfileMinimal.city, isNull);
      expect(tProfileMinimal.country, isNull);
      expect(tProfileMinimal.bio, isNull);
    });

    test('should default isVerified to false', () {
      expect(tProfileMinimal.isVerified, false);
    });

    test('should allow isVerified to be true', () {
      const verified = ProfileEntity(
        id: 'user-003',
        displayName: 'Verified User',
        followersCount: 0,
        followingCount: 0,
        tracksCount: 0,
        isFollowing: false,
        isVerified: true,
      );
      expect(verified.isVerified, true);
    });

    test('should allow isFollowing to be true', () {
      const following = ProfileEntity(
        id: 'user-002',
        displayName: 'Bassel Alaa',
        followersCount: 4120,
        followingCount: 88,
        tracksCount: 23,
        isFollowing: true,
      );
      expect(following.isFollowing, true);
    });
  });

  // ---------------------------------------------------------------------------
  // copyWithFollowing
  // ---------------------------------------------------------------------------

  group('ProfileEntity — copyWithFollowing', () {
    test(
      'should return a new instance with updated isFollowing and followersCount',
      () {
        final updated = tProfile.copyWithFollowing(
          isFollowing: true,
          followersCount: 1241,
        );

        expect(updated.isFollowing, true);
        expect(updated.followersCount, 1241);
      },
    );

    test('should preserve all other fields when copying with follow state', () {
      final updated = tProfile.copyWithFollowing(
        isFollowing: true,
        followersCount: 1241,
      );

      expect(updated.id, tProfile.id);
      expect(updated.displayName, tProfile.displayName);
      expect(updated.username, tProfile.username);
      expect(updated.avatarUrl, tProfile.avatarUrl);
      expect(updated.coverUrl, tProfile.coverUrl);
      expect(updated.city, tProfile.city);
      expect(updated.country, tProfile.country);
      expect(updated.bio, tProfile.bio);
      expect(updated.followingCount, tProfile.followingCount);
      expect(updated.tracksCount, tProfile.tracksCount);
      expect(updated.isVerified, tProfile.isVerified);
    });

    test('should decrement followersCount when unfollowing', () {
      final followed = tProfile.copyWithFollowing(
        isFollowing: true,
        followersCount: 1241,
      );
      final unfollowed = followed.copyWithFollowing(
        isFollowing: false,
        followersCount: 1240,
      );

      expect(unfollowed.isFollowing, false);
      expect(unfollowed.followersCount, 1240);
    });

    test('should not mutate the original instance', () {
      tProfile.copyWithFollowing(isFollowing: true, followersCount: 9999);

      expect(tProfile.isFollowing, false);
      expect(tProfile.followersCount, 1240);
    });

    test('should handle zero followers count', () {
      final updated = tProfileMinimal.copyWithFollowing(
        isFollowing: true,
        followersCount: 1,
      );
      expect(updated.followersCount, 1);
      expect(updated.isFollowing, true);
    });
  });

  // ---------------------------------------------------------------------------
  // Equality (Equatable)
  // ---------------------------------------------------------------------------

  group('ProfileEntity — equality', () {
    test('should return true when two instances have identical fields', () {
      const duplicate = ProfileEntity(
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
      expect(tProfile, equals(duplicate));
    });

    test('should return false when ids differ', () {
      const different = ProfileEntity(
        id: 'user-999',
        displayName: 'KarimWI',
        followersCount: 1240,
        followingCount: 380,
        tracksCount: 14,
        isFollowing: false,
      );
      expect(tProfile, isNot(equals(different)));
    });

    test('should return false when followersCount differs', () {
      final different = tProfile.copyWithFollowing(
        isFollowing: false,
        followersCount: 9999,
      );
      expect(tProfile, isNot(equals(different)));
    });

    test('should return false when isFollowing differs', () {
      final different = tProfile.copyWithFollowing(
        isFollowing: true,
        followersCount: tProfile.followersCount,
      );
      expect(tProfile, isNot(equals(different)));
    });
  });

  // ---------------------------------------------------------------------------
  // props
  // ---------------------------------------------------------------------------

  group('ProfileEntity — props', () {
    test('should expose all fields in props', () {
      expect(tProfile.props.length, 19);
    });

    test('should include null fields in props for minimal profile', () {
      expect(tProfileMinimal.props, contains(null));
    });
  });

  // ---------------------------------------------------------------------------
  // Edge cases
  // ---------------------------------------------------------------------------

  group('ProfileEntity — edge cases', () {
    test('should handle zero counts', () {
      expect(tProfileMinimal.followersCount, 0);
      expect(tProfileMinimal.followingCount, 0);
      expect(tProfileMinimal.tracksCount, 0);
    });

    test('should handle very large follower counts', () {
      const large = ProfileEntity(
        id: 'user-big',
        displayName: 'Big Star',
        followersCount: 10000000,
        followingCount: 1,
        tracksCount: 500,
        isFollowing: false,
      );
      expect(large.followersCount, 10000000);
    });

    test('should handle empty string displayName', () {
      const u = ProfileEntity(
        id: 'user-001',
        displayName: '',
        followersCount: 0,
        followingCount: 0,
        tracksCount: 0,
        isFollowing: false,
      );
      expect(u.displayName, '');
    });
  });
}
