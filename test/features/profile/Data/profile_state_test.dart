import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';
import 'package:rythmify/features/profile/domain/entities/follow_status.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_state.dart';

void main() {
  const tProfile = ProfileEntity(
    id: 'user-123',
    displayName: 'Test User',
    username: 'testuser',
    avatarUrl: 'https://example.com/avatar.jpg',
    followersCount: 10,
    followingCount: 20,
    tracksCount: 5,
    isFollowing: false,
  );

  final tTrack = Track(
    id: 'track-1',
    userId: 'user-123',
    title: 'Track 1',
    artist: 'Test User',
    audioUrl: 'https://example.com/audio.mp3',
    duration: const Duration(seconds: 180),
    createdAt: DateTime(2024),
  );

  group('ProfileInitial', () {
    test('should support value equality', () {
      expect(const ProfileInitial(), const ProfileInitial());
    });
  });

  group('ProfileLoading', () {
    test('should support value equality', () {
      expect(const ProfileLoading(), const ProfileLoading());
    });
  });

  group('ProfileError', () {
    test('should support value equality', () {
      expect(const ProfileError('err'), const ProfileError('err'));
      expect(const ProfileError('err'), isNot(const ProfileError('other')));
    });

    test('should include message in props', () {
      expect(const ProfileError('err').props, ['err']);
    });
  });

  group('ProfileLoaded', () {
    const state = ProfileLoaded(profile: tProfile);

    test('should default likedTracks to empty', () {
      expect(state.likedTracks, []);
    });

    test('should default isLoadingLikes to false', () {
      expect(state.isLoadingLikes, false);
    });

    test('should default hasMoreLikes to true', () {
      expect(state.hasMoreLikes, true);
    });

    test('should default isSaving to false', () {
      expect(state.isSaving, false);
    });

    test('should support value equality', () {
      final tracks = [tTrack];
      final a = ProfileLoaded(
        profile: tProfile,
        likedTracks: tracks,
        isLoadingLikes: true,
      );
      final b = ProfileLoaded(
        profile: tProfile,
        likedTracks: tracks,
        isLoadingLikes: true,
      );

      expect(a, b);
    });

    test('should not equal ProfileLoaded with different profile', () {
      final a = ProfileLoaded(profile: tProfile);
      final b = ProfileLoaded(profile: tProfile.copyWith(displayName: 'Other'));

      expect(a, isNot(b));
    });

    test('should not equal ProfileLoaded with different likedTracks', () {
      final a = ProfileLoaded(profile: tProfile, likedTracks: [tTrack]);
      final b = const ProfileLoaded(profile: tProfile, likedTracks: []);

      expect(a, isNot(b));
    });

    test('should not equal ProfileLoaded with different isLoadingLikes', () {
      const a = ProfileLoaded(profile: tProfile, isLoadingLikes: false);
      const b = ProfileLoaded(profile: tProfile, isLoadingLikes: true);

      expect(a, isNot(b));
    });

    test('should not equal ProfileLoaded with different isSaving', () {
      const a = ProfileLoaded(profile: tProfile, isSaving: false);
      const b = ProfileLoaded(profile: tProfile, isSaving: true);

      expect(a, isNot(b));
    });

    test('should include relevant fields in props', () {
      final tracks = [tTrack];
      final state = ProfileLoaded(
        profile: tProfile,
        likedTracks: tracks,
        isLoadingLikes: true,
        hasMoreLikes: false,
        isSaving: true,
      );

      expect(state.props, [
        tProfile,
        FollowStatus.empty,
        const [], // uploadedTracks
        false, // isLoadingUploads
        true, // hasMoreUploads
        tracks,
        true, // isLoadingLikes
        false, // hasMoreLikes
        const [], // repostedTracks
        false, // isLoadingReposts
        true, // hasMoreReposts
        const [], // playlists
        false, // isLoadingPlaylists
        const [], // albums
        true, // isSaving
        false, // isBlocked
      ]);
    });

    group('copyWith', () {
      const base = ProfileLoaded(profile: tProfile);

      test('should return identical object when no params passed', () {
        final updated = base.copyWith();
        expect(updated, base);
      });

      test('should update profile', () {
        final otherProfile = tProfile.copyWith(displayName: 'New Name');
        final updated = base.copyWith(profile: otherProfile);

        expect(updated.profile, otherProfile);
        expect(updated.likedTracks, base.likedTracks);
      });

      test('should update likedTracks', () {
        final tracks = [tTrack];
        final updated = base.copyWith(likedTracks: tracks);

        expect(updated.likedTracks, tracks);
        expect(updated.profile, base.profile);
      });

      test('should update isLoadingLikes to true', () {
        final updated = base.copyWith(isLoadingLikes: true);
        expect(updated.isLoadingLikes, true);
      });

      test('should update hasMoreLikes to false', () {
        final updated = base.copyWith(hasMoreLikes: false);
        expect(updated.hasMoreLikes, false);
      });

      test('should update isSaving to true', () {
        final updated = base.copyWith(isSaving: true);
        expect(updated.isSaving, true);
      });

      test('should update multiple fields at once', () {
        final tracks = [tTrack];
        final updated = base.copyWith(
          isSaving: true,
          isLoadingLikes: true,
          likedTracks: tracks,
        );

        expect(updated.isSaving, true);
        expect(updated.isLoadingLikes, true);
        expect(updated.likedTracks, tracks);
        expect(base.isLoadingLikes, false);
      });

      test('should update uploadedTracks', () {
        final tracks = [tTrack];
        final updated = base.copyWith(uploadedTracks: tracks);
        expect(updated.uploadedTracks, tracks);
      });

      test('should update repostedTracks', () {
        final tracks = [tTrack];
        final updated = base.copyWith(repostedTracks: tracks);
        expect(updated.repostedTracks, tracks);
      });

      test('should update playlists', () {
        final updated = base.copyWith(playlists: const []);
        expect(updated.playlists, const []);
      });

      test('should update isBlocked', () {
        final updated = base.copyWith(isBlocked: true);
        expect(updated.isBlocked, true);
      });
    });
  });
}
