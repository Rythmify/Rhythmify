import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/core/domain/entities/track.dart';
import 'package:rythmify/features/profile/domain/entities/profile_entity.dart';
import 'package:rythmify/features/profile/domain/repositories/profile_repository.dart';
import 'package:rythmify/features/profile/presentation/pages/likes_page.dart';
import 'package:rythmify/features/profile/presentation/pages/public_profile_page.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_provider.dart';
import 'package:rythmify/features/profile/presentation/providers/profile_state.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockProfileRepository extends Mock implements ProfileRepository {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

const tProfile = ProfileEntity(
  id: 'user-001',
  displayName: 'KarimWI',
  username: 'karimwi',
  avatarUrl: null,
  city: 'Giza',
  country: 'EG',
  followersCount: 1240,
  followingCount: 380,
  tracksCount: 14,
  isFollowing: false,
);

const tProfileFollowing = ProfileEntity(
  id: 'user-002',
  displayName: 'Bassel Alaa',
  followersCount: 4120,
  followingCount: 88,
  tracksCount: 23,
  isFollowing: true,
);

Track makeTrack(String id) => Track(
  id: id,
  userId: 'user-002',
  title: 'Cairo Nights $id',
  artist: 'Bassel Alaa',
  audioUrl: 'https://example.com/$id.mp3',
  duration: const Duration(seconds: 238),
  createdAt: DateTime(2024, 1, 1),
);

// ---------------------------------------------------------------------------
// Test helpers
// ---------------------------------------------------------------------------

/// Builds a [ProviderScope] override that seeds [profileProvider] with [state].
Widget buildWithState(ProfileState state, Widget child) {
  return ProviderScope(
    overrides: [profileProvider.overrideWith(() => _SeedNotifier(state))],
    child: MaterialApp(home: child),
  );
}

/// A minimal notifier that seeds a fixed state for widget tests.
class _SeedNotifier extends ProfileNotifier {
  final ProfileState _seed;

  _SeedNotifier(this._seed);

  @override
  ProfileState build() => _seed;
}
// ---------------------------------------------------------------------------
// LikesPage tests
// ---------------------------------------------------------------------------

void main() {
  group('LikesPage', () {
    testWidgets('should show loading indicator when state is ProfileLoading', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithState(const ProfileLoading(), const LikesPage(userId: 'me')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show empty state when likedTracks is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile, likedTracks: []),
          const LikesPage(userId: 'me'),
        ),
      );

      expect(find.text('No liked tracks yet'), findsOneWidget);
      expect(find.text('Tracks you like will appear here.'), findsOneWidget);
    });

    testWidgets('should render a track list when likedTracks is not empty', (
      tester,
    ) async {
      final tracks = [makeTrack('t1'), makeTrack('t2')];

      await tester.pumpWidget(
        buildWithState(
          ProfileLoaded(profile: tProfile, likedTracks: tracks),
          const LikesPage(userId: 'me'),
        ),
      );

      expect(find.byKey(const Key('item_t1')), findsOneWidget);
      expect(find.byKey(const Key('item_t2')), findsOneWidget);
    });

    testWidgets('should show pagination spinner when isLoadingTracks is true', (
      tester,
    ) async {
      final tracks = [makeTrack('t1')];

      await tester.pumpWidget(
        buildWithState(
          ProfileLoaded(
            profile: tProfile,
            likedTracks: tracks,
            isLoadingLikes: true,
          ),
          const LikesPage(userId: 'me'),
        ),
      );

      // One spinner for pagination at bottom
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should show AppBar with Likes title', (tester) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const LikesPage(userId: 'me'),
        ),
      );

      expect(find.text('Likes'), findsOneWidget);
    });

    testWidgets('should show back button in AppBar', (tester) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const LikesPage(userId: 'me'),
        ),
      );

      expect(find.byKey(const Key('likes_back_button')), findsOneWidget);
    });

    testWidgets('should show cast button in AppBar', (tester) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const LikesPage(userId: 'me'),
        ),
      );

      expect(find.byKey(const Key('likes_cast_button')), findsOneWidget);
    });

    testWidgets('should show SizedBox.shrink when state is ProfileInitial', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithState(const ProfileInitial(), const LikesPage(userId: 'me')),
      );

      // No list, no loading, no error — silent
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show SizedBox.shrink when state is ProfileError', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileError('Error'),
          const LikesPage(userId: 'me'),
        ),
      );

      expect(find.byType(ListView), findsNothing);
    });

    testWidgets(
      'should not show pagination spinner when isLoadingTracks is false',
      (tester) async {
        final tracks = [makeTrack('t1')];

        await tester.pumpWidget(
          buildWithState(
            ProfileLoaded(
              profile: tProfile,
              likedTracks: tracks,
              isLoadingLikes: false,
            ),
            const LikesPage(userId: 'me'),
          ),
        );

        // No CircularProgressIndicator expected
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });

  // =========================================================================
  // PublicProfilePage — widget tests
  // =========================================================================

  group('PublicProfilePage', () {
    testWidgets('should show loading indicator when state is ProfileLoading', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoading(),
          const PublicProfilePage(userId: 'user-002'),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'should show error message and retry button when state is ProfileError',
      (tester) async {
        await tester.pumpWidget(
          buildWithState(
            const ProfileError('User profile not found.'),
            const PublicProfilePage(userId: 'nonexistent'),
          ),
        );

        expect(find.text('User profile not found.'), findsOneWidget);
        expect(
          find.byKey(const Key('public_profile_retry_button')),
          findsOneWidget,
        );
      },
    );

    testWidgets('should render display name when loaded', (tester) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const PublicProfilePage(userId: 'user-001'),
        ),
      );

      expect(find.text('KarimWI'), findsOneWidget);
    });

    testWidgets('should render location when city and country are set', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const PublicProfilePage(userId: 'user-001'),
        ),
      );

      expect(find.text('Giza, EG'), findsOneWidget);
    });

    testWidgets('should show edit button for own profile', (tester) async {
      // userId 'me' → isOwnProfile = true
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const PublicProfilePage(userId: 'me'),
        ),
      );

      expect(
        find.byKey(const Key('public_profile_edit_gesture')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('public_profile_follow_gesture')),
        findsNothing,
      );
    });

    testWidgets('should show Follow button for another user profile', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const PublicProfilePage(userId: 'user-002'),
        ),
      );

      expect(
        find.byKey(const Key('public_profile_follow_gesture')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('public_profile_edit_gesture')),
        findsNothing,
      );
    });

    testWidgets('should show "Following" label when isFollowing is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfileFollowing),
          const PublicProfilePage(userId: 'user-002'),
        ),
      );

      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('should show "Follow" label when isFollowing is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const PublicProfilePage(userId: 'user-002'),
        ),
      );

      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('should show empty state when no liked tracks', (tester) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile, likedTracks: []),
          const PublicProfilePage(userId: 'user-001'),
        ),
      );

      expect(find.text('Seems a little quiet over here'), findsOneWidget);
    });

    testWidgets('should render track tiles when likedTracks is not empty', (
      tester,
    ) async {
      final tracks = [makeTrack('t1'), makeTrack('t2')];

      await tester.pumpWidget(
        buildWithState(
          ProfileLoaded(profile: tProfile, likedTracks: tracks),
          const PublicProfilePage(userId: 'user-001'),
        ),
      );

      expect(find.byKey(const Key('item_t1')), findsOneWidget);
      expect(find.byKey(const Key('item_t2')), findsOneWidget);
    });

    testWidgets('should show back button in AppBar', (tester) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const PublicProfilePage(userId: 'user-001'),
        ),
      );

      expect(
        find.byKey(const Key('public_profile_back_button')),
        findsOneWidget,
      );
    });

    testWidgets('should show more (⋮) button in AppBar', (tester) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const PublicProfilePage(userId: 'user-001'),
        ),
      );

      expect(
        find.byKey(const Key('public_profile_more_button')),
        findsOneWidget,
      );
    });

    testWidgets('should show play button', (tester) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const PublicProfilePage(userId: 'user-001'),
        ),
      );

      expect(
        find.byKey(const Key('public_profile_play_button')),
        findsOneWidget,
      );
    });

    testWidgets('should show shuffle button', (tester) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileLoaded(profile: tProfile),
          const PublicProfilePage(userId: 'user-001'),
        ),
      );

      expect(
        find.byKey(const Key('public_profile_shuffle_gesture')),
        findsOneWidget,
      );
    });

    testWidgets('should show SizedBox.shrink when state is ProfileInitial', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWithState(
          const ProfileInitial(),
          const PublicProfilePage(userId: 'user-001'),
        ),
      );

      // No content rendered yet
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('KarimWI'), findsNothing);
    });

    testWidgets(
      'should show pagination spinner at bottom when loading tracks',
      (tester) async {
        final tracks = [makeTrack('t1')];

        await tester.pumpWidget(
          buildWithState(
            ProfileLoaded(
              profile: tProfile,
              likedTracks: tracks,
              isLoadingLikes: true,
            ),
            const PublicProfilePage(userId: 'user-001'),
          ),
        );

        // Scroll to make the spinner visible
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsWidgets);
      },
    );
  });
}
