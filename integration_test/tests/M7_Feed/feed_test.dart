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

    await tryTest('TC-HOME-001 | Home tab is visible', () async {
      expect(homePage.isHeaderVisible(), true);
    });

    await tryTest('TC-HOME-002 | Bottom nav bar is visible', () async {
      expect(homePage.isAllNavTabsVisible(), true);
    });

    await tryTest('TC-HOME-003 | All header elements are visible', () async {
      expect(homePage.isAllHeaderElementsVisible(), true);
    });

    await tryTest('TC-HOME-004 | Tap message button & notifications button', () async {
      await homePage.tapMessageButton();
      await tester.pump(const Duration(seconds: 3));
      expect(homePage.isOnInboxPage(), true);
      await tester.pageBack();
      await tester.pump(const Duration(seconds: 2));

      await homePage.tapNotificationButton();
      await tester.pump(const Duration(seconds: 3));
      expect(homePage.isOnNotificationsPage(), true);
      await tester.pageBack();
      await tester.pump(const Duration(seconds: 2));
    });

    await tryTest('TC-HOME-005 | Trending by genre visible — tap genres one by one', () async {
      await homePage.scrollDownUntilVisible(trendingByGenreSection);
      expect(homePage.isTrendingByGenreVisible(), true);
      for (final genre in ['Hip-Hop', 'Arabic Pop', 'Arabic Trap', 'R&B', 'Arabic Rock', 'Pop', 'Alternative Rock', 'Indie Rock']) {
        await homePage.tapGenreTab(genre);
      }
      for (final genre in ['Alternative Rock', 'Pop', 'Arabic Rock', 'R&B', 'Arabic Trap', 'Arabic Pop', 'Hip-Hop', 'Indie Rock']) {
        await homePage.tapGenreTab(genre);
      }
      expect(homePage.isTrendingByGenreVisible(), true);
    });

    await tryTest('TC-HOME-006 | User can scroll horizontally in the genre section', () async {
      await homePage.scrollHorizontallyInSection(genreTabBar);
    });

    await tryTest('TC-HOME-007 | Hot For You section visible — play and stop track', () async {
      await homePage.scrollDownUntilVisible(hotForYouSection);
      expect(homePage.isActivityCardVisible(), true);
      await homePage.tapByKeyNow(hotForYouPlayButton);
      await tester.pump(const Duration(seconds: 1));
      await homePage.tapByKeyNow(hotForYouPlayButton);
      await tester.pump(const Duration(seconds: 1));
      expect(homePage.isActionButtonVisible(), true);
      await homePage.pauseIfPlaying();
    });

    await tryTest('TC-HOME-008 | Mixed For You — scroll, open playlist, like, return', () async {
      await homePage.scrollDownUntilVisible(mixedForYouSection);
      expect(homePage.isMixedForYouVisible(), true);
      await tester.pump(const Duration(seconds: 1));
      // Scroll only 100px so items remain at the list-view center for the tap.
      await homePage.scrollHorizontallyInSection(mixedListView, -100);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key(mixedListView)), findsOneWidget,
          reason: 'Mixed For You list must be loaded with data');
      await tester.tap(find.byKey(const Key(mixedListView)), warnIfMissed: false);
      await homePage.settle();

      await homePage.tapMixDetailLikeButton();
      await tester.pump(const Duration(milliseconds: 500));
      await homePage.pauseIfPlaying();
      await homePage.mixedForYouBackButton();
      await homePage.settle();
    });

    await tryTest('TC-HOME-009 | Discover With Stations — scroll, open playlist, like, return', () async {
      await homePage.scrollDownUntilVisible(discoverWithStationsSection);
      expect(homePage.isDiscoverWithStationsVisible(), true);
      await tester.pump(const Duration(seconds: 1));
      // Scroll only 100px so the first card stays at center for the tap.
      await homePage.scrollHorizontallyInSection(discoverListView, -100);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key(discoverListView)), findsOneWidget,
          reason: 'Discover With Stations list must be loaded with data');
      await tester.tap(find.byKey(const Key(discoverListView)), warnIfMissed: false);
      await homePage.settle();

      // Station route opens RelatedTracksScreen — use its like/back keys.
      await homePage.tapRelatedTracksLikeButton();
      await tester.pump(const Duration(milliseconds: 500));
      await homePage.pauseIfPlaying();
      await homePage.relatedTracksBackButton();
      await homePage.settle();
    });

    await tryTest('TC-HOME-010 | More of What You Like — scroll, open playlist, like, return', () async {
      await homePage.scrollDownUntilVisible(moreOfWhatYouLikeSection);
      expect(homePage.isMoreOfWhatYouLikeVisible(), true);
      await tester.pump(const Duration(seconds: 1));
      // Scroll only 100px so the first card stays at center for the tap.
      await homePage.scrollHorizontallyInSection(moreListView, -100);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const Key(moreListView)), findsOneWidget,
          reason: 'More of What You Like list must be loaded with data');
      await tester.tap(find.byKey(const Key(moreListView)), warnIfMissed: false);
      await homePage.settle();

      // More of What You Like opens RelatedTracksScreen — use its like/back keys.
      await homePage.tapRelatedTracksLikeButton();
      await tester.pump(const Duration(milliseconds: 500));
      await homePage.pauseIfPlaying();
      await homePage.relatedTracksBackButton();
      await homePage.settle();
    });
    
    await homePage.pauseIfPlaying();

    // ══ Feed Page test cases ═════════════════════════════════════════════
    final feedPage = FeedPage(tester);
    await tester.pump(const Duration(seconds: 2));
    debugPrint('M7 - Feed Page - all scenarios');

    await tryTest('TC-FEED-001 | Navigate to feed page successfully', () async {
      await feedPage.tapFeedButton();
      await tester.pump(const Duration(seconds: 3));
    });

    await tryTest('TC-FEED-002 | Tap following & discover buttons', () async {
      await feedPage.tapFollowingButton();
      await tester.pump(const Duration(seconds: 3));
      await feedPage.tapDiscoverButton();
      await tester.pump(const Duration(seconds: 3));
      await feedPage.tapFollowingButton();
      await tester.pump(const Duration(seconds: 3));
    });

    await tryTest('TC-FEED-003 | Tap like button', () async {
      await feedPage.taplikeButton();
      await tester.pump(const Duration(milliseconds: 500));
    });

    await tryTest('TC-FEED-004 | Tap comment button and navigate back', () async {
      await feedPage.tapCommentButton();
      await tester.pump(const Duration(seconds: 2));
      await feedPage.closeComments();
      await tester.pump(const Duration(seconds: 1));
    });

    await tryTest('TC-FEED-005 | Open full player via track card and collapse back', () async {
      await feedPage.dragTrackCard();
      await tester.pump(const Duration(seconds: 3));
      expect(feedPage.playerTrack(), true);
      await homePage.pauseIfPlaying();
      await feedPage.tapDragtButton();
      await tester.pump(const Duration(seconds: 2));
    });

    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}
