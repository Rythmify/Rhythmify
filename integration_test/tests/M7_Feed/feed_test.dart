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
    expect(homePage.isHeaderVisible(), true);

    // ─── TC-HOME-002 | Bottom nav bar is visible ──────────────────────────
    expect(homePage.isAllNavTabsVisible(), true);

    // ─── TC-HOME-003 | All header elements are visible ────────────────────
    expect(homePage.isAllHeaderElementsVisible(), true);

    // ─── TC-HOME-004 | tap message button & notifications button ───────────────
    await homePage.tapMessageButton();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(homePage.isOnInboxPage(), true);
    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await homePage.tapNotificationButton();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await homePage.isOnNotificationsPage();
    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 3));
  

    // ─── TC-HOME-004 | Trending by genre visible — tap genres one by one ──
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

    // ─── TC-HOME-005 | User can scroll horizontally in the genre section ──
    await homePage.scrollHorizontallyInSection(genreTabBar);

    // ─── TC-HOME-006 | Hot For You section visible — play and stop track ──
    expect(homePage.isActivityCardVisible(), true);
    await homePage.tapByKeyNow(hotForYouPlayButton);
    await tester.pump(const Duration(seconds: 1));
    await homePage.tapByKeyNow(hotForYouPlayButton);
    await tester.pump(const Duration(seconds: 1));
    expect(homePage.isActionButtonVisible(), true);

    // ─── TC-HOME-007 | Mixed For You visible — scroll horizontally ────────
    await homePage.scrollDownUntilVisible(mixedForYouSection);
    expect(homePage.isMixedForYouVisible(), true);
    await homePage.tapMixedForYou();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.pageBack(); //need to change this to tap back button key once implemented
    await homePage.scrollHorizontallyInSection(mixedListView);

    // ─── TC-HOME-008 | Discover With Stations visible — scroll horizontally
    await homePage.scrollDownUntilVisible(discoverWithStationsSection);
    expect(homePage.isDiscoverWithStationsVisible(), true);
    await homePage.tapDiscoverWithStations();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.pageBack();   //need to change this to tap back button key once implemented
    await homePage.scrollHorizontallyInSection(discoverWithStationsSection);

    // ─── TC-HOME-009 | More of What You Like visible — scroll horizontally ─
    await homePage.scrollDownUntilVisible(moreOfWhatYouLikeSection);
    expect(homePage.isMoreOfWhatYouLikeVisible(), true);
    await homePage.tapMoreOfWhatYouLike();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await tester.pageBack();   //need to change this to tap back button key once implemented
    await homePage.scrollHorizontallyInSection(moreListView);

    // ── Feed Page test Case ──  
    // debugPrint('M7 - Feed Page - all scenarios');
    // await FeedPage.tapFeedButton();
    // await tester.pumpAndSettle(const Duration(seconds: 3));
    // await FeedPage.tapFollowingButton();
    // await tester.pumpAndSettle(const Duration(seconds: 3));
    // await FeedPage.tapDiscoverButton();
    // await tester.pumpAndSettle(const Duration(seconds: 3));
    // await FeedPage.tapTrack();
    // await FeedPage.taplikeButton();
    // await FeedPage.tapCommentButton();
    // await FeedPage.CloseCommentSection();
    // await FeedPage.DragTrackCard();
    // await tester.pumpAndSettle(const Duration(seconds: 3));
    // await FeedPage.tapDragtButton();
    // await tester.pumpAndSettle(const Duration(seconds: 3));
    // await FeedPage.scrollDown();
    // await tester.pumpAndSettle(const Duration(seconds: 3));
    // await FeedPage.scrollUp();
    // await tester.pumpAndSettle(const Duration(seconds: 3));
    // await FeedPage.tapTrack();
  });
}
