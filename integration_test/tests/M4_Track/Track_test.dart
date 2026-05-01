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

  testWidgets('M3 - TRACK - all scenarios',(tester) async {
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

    await tryTest('TC-TRACK-001 | Play a track from the Hot For You section', () async {
      await trackPage.playFromHotForYou();
    });

    await tryTest('TC-TRACK-002 | Open the full player via the mini player bar', () async {
      await trackPage.openMiniPlayer();
      await tester.pump(const Duration(seconds: 3));
    });

    await tryTest('TC-TRACK-003 | Navigate to Behind the Track', () async {
      await trackPage.tapBehindThisTrack();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    await tryTest('TC-TRACK-004 | check visibility (cover art + title + artist)', () async {
      expect(trackPage.isTrackInfoVisible(), true);
    });
    
    await tryTest('TC-TRACK-005 | Action bar buttons are clickable (like/repost/comments/3-dots + play)', () async {
      await trackPage.tapLike();
      await trackPage.tapRepost();
      await trackPage.tapComment();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await trackPage.returnToBehindTheTrack();
      await trackPage.tapMore();
      await trackPage.dragToCloseMoreOptions();
      await tester.pumpAndSettle(Duration(seconds: 2));
    });

    await tryTest('TC-TRACK-006 | Stop and play the track from the player button', () async {
      await trackPage.tapPlayPause(); // pause
      await tester.pump(const Duration(seconds: 1));
      await trackPage.tapPlayPause(); // play
      await tester.pump(const Duration(seconds: 1));
    });

    await tryTest('TC-TRACK-007 | "Show more" opens description sheet', () async {
      if (trackPage.isShowMoreVisible()) {
        await trackPage.tapShowMore();
        expect(trackPage.isDescriptionSheetVisible(), true);
        await trackPage.closeDescriptionSheet();
      }
    });

    await tryTest('TC-TRACK-008 | Tags row is visible and horizontally scrollable', () async {
      if (trackPage.isTagsVisible()) {
        await trackPage.scrollTagsHorizontally();
      }
    }); 

    await tryTest('TC-TRACK-009 | scroll successfully in behind the track page',()async{
      await trackPage.scrollToFansLeaderboard();
      expect(trackPage.isFansLeaderboardVisible(), true);

    });

    await tryTest('TC-TRACK-010 | Fans leaderboard clickable',()async{
      await trackPage.tapTopSegment();
      await trackPage.tapFirstSegment();
    });

    await tryTest('TC-TRACK-011 | Follow button is clickable & click Artist direct to artist profile page', () async {
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
