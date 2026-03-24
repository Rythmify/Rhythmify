import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_state.dart';

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

final tTrack = Track(
  id: 'track-001',
  userId: 'user-002',
  title: 'Cairo Nights',
  artist: 'Bassel Alaa',
  audioUrl: 'https://example.com/audio.mp3',
  duration: const Duration(seconds: 238),
  createdAt: DateTime(2024, 1, 1),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // ProfileInitial
  // =========================================================================

  group('ProfileInitial', () {
    test('should be a subtype of ProfileState', () {
      expect(const ProfileInitial(), isA<ProfileState>());
    });

    test('should equal another ProfileInitial instance', () {
      expect(const ProfileInitial(), equals(const ProfileInitial()));
    });

    test('should have empty props', () {
      expect(const ProfileInitial().props, isEmpty);
    });

    test('should not equal ProfileLoading', () {
      expect(const ProfileInitial(), isNot(equals(const ProfileLoading())));
    });
  });

  // =========================================================================
  // ProfileLoading
  // =========================================================================

  group('ProfileLoading', () {
    test('should be a subtype of ProfileState', () {
      expect(const ProfileLoading(), isA<ProfileState>());
    });

    test('should equal another ProfileLoading instance', () {
      expect(const ProfileLoading(), equals(const ProfileLoading()));
    });

    test('should have empty props', () {
      expect(const ProfileLoading().props, isEmpty);
    });

    test('should not equal ProfileInitial', () {
      expect(const ProfileLoading(), isNot(equals(const ProfileInitial())));
    });
  });

  // =========================================================================
  // ProfileError
  // =========================================================================

  group('ProfileError', () {
    test('should be a subtype of ProfileState', () {
      expect(const ProfileError('error'), isA<ProfileState>());
    });

    test('should store the error message', () {
      const state = ProfileError('User profile not found.');
      expect(state.message, 'User profile not found.');
    });

    test('should equal another ProfileError with the same message', () {
      expect(
        const ProfileError('Not found'),
        equals(const ProfileError('Not found')),
      );
    });

    test('should not equal ProfileError with a different message', () {
      expect(
        const ProfileError('Error A'),
        isNot(equals(const ProfileError('Error B'))),
      );
    });

    test('should include message in props', () {
      const state = ProfileError('oops');
      expect(state.props, ['oops']);
    });

    test('should handle empty string message', () {
      const state = ProfileError('');
      expect(state.message, '');
      expect(state.props, ['']);
    });
  });

  // =========================================================================
  // ProfileLoaded — construction
  // =========================================================================

  group('ProfileLoaded — construction', () {
    test('should store the profile', () {
      const state = ProfileLoaded(profile: tProfile);
      expect(state.profile, tProfile);
    });

    test('should default likedTracks to empty list', () {
      const state = ProfileLoaded(profile: tProfile);
      expect(state.likedTracks, isEmpty);
    });

    test('should default isLoadingTracks to false', () {
      const state = ProfileLoaded(profile: tProfile);
      expect(state.isLoadingTracks, false);
    });

    test('should default hasMoreTracks to true', () {
      const state = ProfileLoaded(profile: tProfile);
      expect(state.hasMoreTracks, true);
    });

    test('should default isSaving to false', () {
      const state = ProfileLoaded(profile: tProfile);
      expect(state.isSaving, false);
    });

    test('should accept explicit values for all optional fields', () {
      final state = ProfileLoaded(
        profile: tProfile,
        likedTracks: [tTrack],
        isLoadingTracks: true,
        hasMoreTracks: false,
        isSaving: true,
      );

      expect(state.likedTracks, [tTrack]);
      expect(state.isLoadingTracks, true);
      expect(state.hasMoreTracks, false);
      expect(state.isSaving, true);
    });

    test('should be a subtype of ProfileState', () {
      expect(const ProfileLoaded(profile: tProfile), isA<ProfileState>());
    });
  });

  // =========================================================================
  // ProfileLoaded — equality
  // =========================================================================

  group('ProfileLoaded — equality', () {
    test('should equal another ProfileLoaded with identical fields', () {
      const a = ProfileLoaded(profile: tProfile);
      const b = ProfileLoaded(profile: tProfile);
      expect(a, equals(b));
    });

    test('should not equal ProfileLoaded with a different profile', () {
      const other = ProfileEntity(
        id: 'user-002',
        displayName: 'Bassel Alaa',
        followersCount: 0,
        followingCount: 0,
        tracksCount: 0,
        isFollowing: false,
      );
      expect(
        const ProfileLoaded(profile: tProfile),
        isNot(equals(const ProfileLoaded(profile: other))),
      );
    });

    test('should not equal ProfileLoaded with different isSaving', () {
      const a = ProfileLoaded(profile: tProfile, isSaving: false);
      const b = ProfileLoaded(profile: tProfile, isSaving: true);
      expect(a, isNot(equals(b)));
    });

    test('should not equal ProfileLoaded with different isLoadingTracks', () {
      const a = ProfileLoaded(profile: tProfile, isLoadingTracks: false);
      const b = ProfileLoaded(profile: tProfile, isLoadingTracks: true);
      expect(a, isNot(equals(b)));
    });

    test('should not equal ProfileLoaded with different hasMoreTracks', () {
      const a = ProfileLoaded(profile: tProfile, hasMoreTracks: true);
      const b = ProfileLoaded(profile: tProfile, hasMoreTracks: false);
      expect(a, isNot(equals(b)));
    });

    test('should not equal ProfileError with same message content', () {
      expect(
        const ProfileLoaded(profile: tProfile),
        isNot(equals(const ProfileError('error'))),
      );
    });
  });

  // =========================================================================
  // ProfileLoaded — props
  // =========================================================================

  group('ProfileLoaded — props', () {
    test('should expose exactly 5 fields in props', () {
      const state = ProfileLoaded(profile: tProfile);
      expect(state.props.length, 5);
    });

    test('should include profile, likedTracks, isLoadingTracks, hasMoreTracks, isSaving in props',
        () {
      final state = ProfileLoaded(
        profile: tProfile,
        likedTracks: [tTrack],
        isLoadingTracks: true,
        hasMoreTracks: false,
        isSaving: true,
      );

      expect(state.props[0], tProfile);
      expect(state.props[1], [tTrack]);
      expect(state.props[2], true);   // isLoadingTracks
      expect(state.props[3], false);  // hasMoreTracks
      expect(state.props[4], true);   // isSaving
    });
  });

  // =========================================================================
  // ProfileLoaded.copyWith
  // =========================================================================

  group('ProfileLoaded.copyWith', () {
    const base = ProfileLoaded(profile: tProfile);

    test('should return identical state when no fields are changed', () {
      final copy = base.copyWith();
      expect(copy, equals(base));
    });

    test('should update profile only', () {
      final updated = base.copyWith(profile: tProfileFollowing);
      expect(updated.profile, tProfileFollowing);
      expect(updated.isSaving, base.isSaving);
      expect(updated.likedTracks, base.likedTracks);
      expect(updated.isLoadingTracks, base.isLoadingTracks);
      expect(updated.hasMoreTracks, base.hasMoreTracks);
    });

    test('should update isSaving to true', () {
      final updated = base.copyWith(isSaving: true);
      expect(updated.isSaving, true);
      expect(updated.profile, base.profile);
    });

    test('should update isSaving back to false', () {
      const saving = ProfileLoaded(profile: tProfile, isSaving: true);
      final updated = saving.copyWith(isSaving: false);
      expect(updated.isSaving, false);
    });

    test('should update isLoadingTracks to true', () {
      final updated = base.copyWith(isLoadingTracks: true);
      expect(updated.isLoadingTracks, true);
      expect(updated.profile, base.profile);
    });

    test('should update hasMoreTracks to false', () {
      final updated = base.copyWith(hasMoreTracks: false);
      expect(updated.hasMoreTracks, false);
    });

    test('should update likedTracks with new list', () {
      final updated = base.copyWith(likedTracks: [tTrack]);
      expect(updated.likedTracks, [tTrack]);
      expect(updated.profile, base.profile);
    });

    test('should update likedTracks to empty list (refresh reset)', () {
      final withTracks = base.copyWith(likedTracks: [tTrack]);
      final reset = withTracks.copyWith(likedTracks: []);
      expect(reset.likedTracks, isEmpty);
    });

    test('should update multiple fields at once', () {
      final updated = base.copyWith(
        isLoadingTracks: true,
        hasMoreTracks: true,
        likedTracks: [],
      );
      expect(updated.isLoadingTracks, true);
      expect(updated.hasMoreTracks, true);
      expect(updated.likedTracks, isEmpty);
      expect(updated.isSaving, false);
    });

    test('should not mutate the original state', () {
      base.copyWith(isSaving: true, isLoadingTracks: true);

      expect(base.isSaving, false);
      expect(base.isLoadingTracks, false);
    });

    test('should create a new object reference', () {
      final copy = base.copyWith();
      expect(identical(base, copy), false);
    });

    test('should preserve large likedTracks list when updating other fields',
        () {
      final manyTracks = List.generate(
        20,
        (i) => Track(
          id: 'track-$i',
          userId: 'user-001',
          title: 'Track $i',
          artist: 'Artist',
          audioUrl: 'https://example.com/$i.mp3',
          duration: const Duration(seconds: 200),
          createdAt: DateTime(2024, 1, 1),
        ),
      );
      final withTracks = base.copyWith(likedTracks: manyTracks);
      final updated = withTracks.copyWith(isSaving: true);

      expect(updated.likedTracks.length, 20);
      expect(updated.isSaving, true);
    });
  });
}
