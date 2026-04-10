import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M4_Track/Track_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-TRACK-001 | Behind the Track — all sections visible & interactive',
      (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final loginPage = LoginPage(tester);
    final trackPage = TrackPage(tester);

    // ── Login ──────────────────────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(loginPage.isOnHomePage(), true);

    // ── Play a track from the Hot For You section ──────────────────────────
    await trackPage.playFromHotForYou();

    // ── Open the full player via the mini player bar ───────────────────────
    await trackPage.openMiniPlayer();

    // ── Navigate to Behind the Track ──────────────────────────────────────
    await trackPage.tapBehindThisTrack();

    // ── TC-TRACK-001 | Track info (cover art + title + artist) is visible ─
    expect(trackPage.isTrackInfoVisible(), true);

    // ── TC-TRACK-002 | Action bar (like/repost/comments/3-dots + play) ───
    expect(trackPage.isActionBarVisible(), true);

    // ── TC-TRACK-003 | Stop and play the track from the player button ─────
    await trackPage.tapPlayPause(); // pause
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await trackPage.tapPlayPause(); // play
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // ── TC-TRACK-004 | "Show more" opens description sheet ───────────────
    if (trackPage.isShowMoreVisible()) {
      await trackPage.tapShowMore();
      expect(trackPage.isDescriptionSheetVisible(), true);
      await trackPage.closeDescriptionSheet();
    }

    // ── TC-TRACK-005 | Tags row is visible and horizontally scrollable ────
    if (trackPage.isTagsVisible()) {
      await trackPage.scrollTagsHorizontally();
    }

    // ── TC-TRACK-006 | Artist section + Follow button are visible ─────────
    expect(trackPage.isFollowButtonVisible(), true);
    await trackPage.tapFollowButton();

    // ── TC-TRACK-007 | Scroll to Fans Leaderboard ────────────────────────
    await trackPage.scrollToFansLeaderboard();
    expect(trackPage.isFansLeaderboardVisible(), true);

    // ── TC-TRACK-008 | Top / First segment buttons are tappable ──────────
    await trackPage.tapTopSegment();
    await trackPage.tapFirstSegment();
  });
}
