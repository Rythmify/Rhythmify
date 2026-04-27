import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M7_Feed/home_page.dart';
import '../../pages/M7_Feed/feed_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('M7 - Home Page - all scenarios', (tester) async {
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

    // ── Login first ──
    final loginPage = LoginPage(tester);
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(loginPage.isOnHomePage(), true);

    final homePage = HomePage(tester);

    // ─── TC-HOME-001 | Home tab is visible ───────────────────────────────
    await tryTest('TC-HOME-001 | Home tab is visible', () async {
      expect(homePage.isHeaderVisible(), true);
    });

    // ─── TC-HOME-002 | Bottom nav bar is visible ──────────────────────────
    await tryTest('TC-HOME-002 | Bottom nav bar is visible', () async {
        expect(homePage.isAllNavTabsVisible(), true);
    });

    // ─── TC-HOME-003 | All header elements are visible ────────────────────
    await tryTest('TC-HOME-003 | All header elements are visible', () async {
      expect(homePage.isAllHeaderElementsVisible(), true);
    });

    // ─── TC-HOME-004 | tap message button & notifications button ───────────────
    await tryTest('TC-HOME-004 | tap message button & notifications button', () async {
      await homePage.tapMessageButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(homePage.isOnInboxPage(), true);
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await homePage.tapNotificationButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect (homePage.isOnNotificationsPage(), true);
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

  
    // ─── TC-HOME-004 | Trending by genre visible — tap genres one by one ──
    await tryTest('TC-HOME-004 | Trending by genre visible — tap genres one by one', () async {
      await homePage.scrollDownUntilVisible(trendingByGenreSection);
      expect(homePage.isTrendingByGenreVisible(), true);
      for (final genre in ['Electronic', 'Hip-Hop & Rap','Synth-Pop','Indie','Jazz','Lo-Fi','Ambient', 'R&B / Soul']) {
        await homePage.tapGenreTab(genre);
      }
      expect(homePage.isTrendingByGenreVisible(), true);

      expect(homePage.isTrendingByGenreVisible(), true);
      for (final genre in ['R&B / Soul','Ambient','Lo-Fi','Jazz','Indie','Synth-Pop', 'Hip-Hop & Rap', 'Electronic']) {
        await homePage.tapGenreTab(genre);
      }
      expect(homePage.isTrendingByGenreVisible(), true);
    });

    // ─── TC-HOME-005 | User can scroll horizontally in the genre section ──
    await tryTest('TC-HOME-005 | User can scroll horizontally in the genre section', () async {
      await homePage.scrollHorizontallyInSection(genreTabBar);
    });

    // ─── TC-HOME-006 | Hot For You section visible — play and stop track ──
    await tryTest('TC-HOME-006 | Hot For You section visible — play and stop track', () async {
      await homePage.scrollDownUntilVisible(hotForYouSection);
      expect(homePage.isActivityCardVisible(), true);
      await homePage.tapByKeyNow(hotForYouPlayButton);
      await tester.pump(const Duration(seconds: 1));
      await homePage.tapByKeyNow(hotForYouPlayButton);
      await tester.pump(const Duration(seconds: 1));
      expect(homePage.isActionButtonVisible(), true);
    });

    // ─── TC-HOME-007 | Mixed For You visible — scroll horizontally ────────
    await tryTest('TC-HOME-007 | Mixed For You visible — scroll horizontally', () async {
      await homePage.scrollDownUntilVisible(mixedForYouSection);
      expect(homePage.isMixedForYouVisible(), true);
      await homePage.tapMixedForYou();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await homePage.mixedForYouBackButton();
      await homePage.scrollHorizontallyInSection(mixedListView);
    });

    // ─── TC-HOME-008 | Discover With Stations visible — scroll horizontally
    await tryTest('TC-HOME-008 | Discover With Stations visible — scroll horizontally', () async {
      await homePage.scrollDownUntilVisible(discoverWithStationsSection);
      expect(homePage.isDiscoverWithStationsVisible(), true);
      await homePage.tapDiscoverWithStations();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await homePage.relatedTracksBackButton(); 
      await homePage.scrollHorizontallyInSection(discoverWithStationsSection);
    });

    // ─── TC-HOME-009 | More of What You Like visible — scroll horizontally ─
    await tryTest('TC-HOME-009 | More of What You Like visible — scroll horizontally', () async {
      await homePage.scrollDownUntilVisible(moreOfWhatYouLikeSection);
      expect(homePage.isMoreOfWhatYouLikeVisible(), true);
      await homePage.tapMoreOfWhatYouLike();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await homePage.relatedTracksBackButton();
      await homePage.scrollHorizontallyInSection(moreListView);
    });

    // ── Feed Page test Case ──  
    final feedPage =  FeedPage(tester);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    debugPrint('M7 - Feed Page - all scenarios');
    await tryTest('TC-FEED-001 | Navigate to feed page successfully', () async {
      await feedPage.tapFeedButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    await tryTest('TC-FEED-002 | Tap following, discoverbuttons', () async {
      await feedPage.tapFollowingButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await feedPage.tapDiscoverButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await feedPage.tapFollowingButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    await tryTest('TC-FEED-003 | Tap like button', () async {
      await feedPage.taplikeButton();
    });

    await tryTest('TC-FEED-004 | Tap comment button and navigate back', () async {
      await feedPage.tapCommentButton();
      await feedPage.closeComments();
    });

    await tryTest('TC-FEED-005 | Drag Player page using Track card and navigate back', () async {
      await feedPage.dragTrackCard();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(feedPage.playerTrack(), true);
      await feedPage.tapDragtButton();
    });

    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}
