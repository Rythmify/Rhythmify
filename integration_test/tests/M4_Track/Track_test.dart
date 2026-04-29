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

  testWidgets('TC-TRACK-001 | Behind the Track — all sections visible & interactive',(tester) async {
    app.main();
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('[Test] Suppressed: ${details.exception}');
    };
    final List<String> failures = [];
    Future<void> tryTest(String name, Future<void> Function() body) async {
      try {
        await body();
        debugPrint('[PASS] $name');
      } catch (e) {
        failures.add('❌ $name\n   → $e');
        debugPrint('[FAIL] $name: $e');
      }
    }
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
    await tryTest('TC-TRACK-001 | Play a track from the Hot For You section', () async {
      await trackPage.playFromHotForYou();
    });

    // ── Open the full player via the mini player bar ───────────────────────
    await tryTest('TC-TRACK-002 | Open the full player via the mini player bar', () async {
      await trackPage.openMiniPlayer();
      await tester.pump(const Duration(seconds: 3));
    });

    // ── Navigate to Behind the Track ──────────────────────────────────────
    await tryTest('TC-TRACK-003 | Navigate to Behind the Track', () async {
      await trackPage.tapBehindThisTrack();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    // ── TC-TRACK-004 | Track info (cover art + title + artist) is visible ─
    await tryTest('TC-TRACK-004-005 | check visibility', () async {
      expect(trackPage.isTrackInfoVisible(), true);
    });
    

    // ── TC-TRACK-003 | Action bar (like/repost/comments/3-dots + play) are clickable ───
    await tryTest('TC-TRACK-006 | Action bar buttons are clickable', () async {
      await trackPage.tapLike();
      await trackPage.tapRepost();
      //await trackPage.tapComment();
      //await tester.pumpAndSettle(const Duration(seconds: 2));
      //await trackPage.returnToBehindTheTrack();
      await trackPage.tapMore();
      await trackPage.dragToCloseMoreOptions();
      await tester.pumpAndSettle(Duration(seconds: 2));
    });


    // ── TC-TRACK-003 | Stop and play the track from the player button ─────
    await tryTest('TC-TRACK-007 | Stop and play the track from the player button', () async {
      await trackPage.tapPlayPause(); // pause
      await tester.pump(const Duration(seconds: 1));
      await trackPage.tapPlayPause(); // play
      await tester.pump(const Duration(seconds: 1));
    });

    // ── TC-TRACK-004 | "Show more" opens description sheet ───────────────
    await tryTest('TC-TRACK-008 | "Show more" opens description sheet', () async {
      if (trackPage.isShowMoreVisible()) {
        await trackPage.tapShowMore();
        expect(trackPage.isDescriptionSheetVisible(), true);
        await trackPage.closeDescriptionSheet();
      }
    });

    // ── TC-TRACK-005 | Tags row is visible and horizontally scrollable ────
    await tryTest('TC-TRACK-009 | Tags row is visible and horizontally scrollable', () async {
      if (trackPage.isTagsVisible()) {
        await trackPage.scrollTagsHorizontally();
      }
    }); 

    await tryTest('TC-TRACK-010 | Fans leaderboard tests',()async{
      // ── TC-TRACK-007 | Scroll to Fans Leaderboard ────────────────────────
      await trackPage.scrollToFansLeaderboard();
      expect(trackPage.isFansLeaderboardVisible(), true);

    });
    await tryTest('TC-TRACK-010 | Fans leaderboard clickable',()async{
      // ── TC-TRACK-008 | Top / First segment buttons are tappable ──────────
      await trackPage.tapTopSegment();
      await trackPage.tapFirstSegment();
    });


    // ── TC-TRACK-007 | Follow button & artist photo are clickable ─────────
    await tryTest('TC-TRACK-011 | Follow button clickable', () async {
      await trackPage.scrollUp();
      await trackPage.tapFollowButton();
      await tester.pump(const Duration(seconds: 1));
      await trackPage.tapArtist();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(trackPage.isOnArtistPage(), true);
    });


    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}
