import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M7_Feed/home_page.dart';
import '../../pages/M7_Feed/feed_page.dart';
import '../../pages/M7_Feed/search_page.dart';
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
    

    final searchPage = SearchPage(tester);
    // ─── TC-SEARCH-001 | Navigate to Search tab ───────────────────────────
    debugPrint('M8 - Search Page - all scenarios');
    await searchPage.tapSearchNavButton();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(searchPage.isSearchScreenVisible(), true);

    // ─── TC-SEARCH-002 | Scroll vibes section down then up ───────────────
    await searchPage.scrollVibesDown();
    await searchPage.scrollVibesUp();

    // ─── TC-SEARCH-003 | Tap a Vibe card → land on vibe detail screen ────
    await searchPage.tapVibeCard('Ambient');
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(searchPage.isVibeDetailScreenVisible(), true);

    // ─── TC-SEARCH-004 | All inner tabs are tappable ─────────────────────────
    await searchPage.tapTrendingVibeTab();
    await searchPage.tapPlaylistsVibeTab();
    await searchPage.tapAlbumsVibeTab();
    await searchPage.tapAllVibeTab();

    // ─── TC-SEARCH-005 | Scroll up and down inside vibe detail ───────────
    await searchPage.scrollVibeDetailDown();
    await searchPage.scrollVibeDetailUp();

    // ─── TC-SEARCH-006 | Switch tabs by swiping horizontally ─────────────
    await searchPage.swipeVibeDetailLeft();   // All → Trending
    await searchPage.swipeVibeDetailLeft();   // Trending → Playlists
    await searchPage.swipeVibeDetailLeft();   // Playlists → Albums
    await searchPage.swipeVibeDetailRight();  // back to Playlists
    await searchPage.swipeVibeDetailRight();  // back to Trending
    await searchPage.swipeVibeDetailRight();  // back to All
    expect(searchPage.isVibeDetailScreenVisible(), true);

    // ─── TC-SEARCH-007 | Back → main search screen ───────────────────────
    await searchPage.tapBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(searchPage.isSearchScreenVisible(), true);

    // ─── TC-SEARCH-008 | Type "A" → suggestion list appears (no Enter) ───
    await searchPage.tapSearchBar();
    await searchPage.typeQuery('A');
    expect(searchPage.isSuggestionListVisible(), true,
        reason: 'Typing "A" should surface a suggestion list');

    // ─── TC-SEARCH-009 | Type "z" → no results in suggestions ───────────
    await searchPage.typeQuery('z');
    expect(searchPage.isNoResultsVisible(), true,
        reason: 'Typing "z" should show "No results found" in suggestions');

    // ─── TC-SEARCH-010 | Search "Yo" → submit → results screen ──────────
    await searchPage.typeQuery('Yo');
    await searchPage.submitSearch();
    expect(searchPage.isResultsScreenVisible(), true,
        reason: 'Searching "Yo" should navigate to the results screen');

    // ─── TC-SEARCH-011 | Scroll results down and up ───────────────────────
    await searchPage.scrollResultsDown();
    await searchPage.scrollResultsUp();
    expect(searchPage.isResultsScreenVisible(), true);

    // ─── TC-SEARCH-012 | Play a track from results ────────────────────────
    await searchPage.tapFirstTrackInResults();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(searchPage.isMiniPlayerVisible(), true,
        reason: 'Mini player should appear after playing a track');

    // ─── TC-SEARCH-013 | Tap each result tab — all are tappable ──────────────
    await searchPage.tapTracksResultsTab();
    await searchPage.tapProfilesResultsTab();
    await searchPage.tapPlaylistsResultsTab();
    await searchPage.tapAlbumsResultsTab();
    await searchPage.tapAllResultsTab();

    // ─── TC-SEARCH-014 | Switch result tabs by swiping horizontally ──────
    await searchPage.swipeResultsLeft();   // All → Tracks
    await searchPage.swipeResultsLeft();   // Tracks → Profiles
    await searchPage.swipeResultsLeft();   // Profiles → Playlists
    await searchPage.swipeResultsLeft();   // Playlists → Albums
    await searchPage.swipeResultsRight();  // Albums → Playlists
    expect(searchPage.isResultsScreenVisible(), true);

    // ─── TC-SEARCH-015 | Tap × → return to main search screen ───────────
    await searchPage.clearSearch();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(searchPage.isSearchScreenVisible(), true,
        reason: 'Clearing search should return to the vibes screen');

  });
}
