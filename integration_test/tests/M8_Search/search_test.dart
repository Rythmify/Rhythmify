import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M8_Search/search_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M8 - Search Page - all scenarios', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ── Login ────────────────────────────────────────────────────────────────
    final loginPage  = LoginPage(tester);
    final searchPage = SearchPage(tester);

    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(loginPage.isOnHomePage(), true);

    // ── Navigate to Search ───────────────────────────────────────────────────
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