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

    // ── Login ────────────────────────────────────────────────────────────────
    final loginPage  = LoginPage(tester);
    final searchPage = SearchPage(tester);

    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(loginPage.isOnHomePage(), true);

    await tryTest('TC-SEARCH-001 | Navigate to Search tab', () async {
      await searchPage.tapSearchNavButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(searchPage.isSearchScreenVisible(), true);
    });

    await tryTest('TC-SEARCH-002 | Scroll vibes section down then up', () async {
      await searchPage.scrollVibesDown();
      await searchPage.scrollVibesUp();
    });

    await tryTest('TC-SEARCH-003 | Tap a Vibe card → land on vibe detail screen', () async {
      await searchPage.tapVibeCard('Alternative Rock');
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(searchPage.isVibePageScreenVisible(), true);
    });

    await tryTest('TC-SEARCH-004/005 | Tap all vibe detail tabs and scroll', () async {
      await searchPage.tapTrendingVibeTab();
      await searchPage.scrollVibeDetailDown();
      await searchPage.scrollVibeDetailUp();

      await searchPage.tapPlaylistsVibeTab();
      await searchPage.scrollVibeDetailDown();
      await searchPage.scrollVibeDetailUp();

      await searchPage.tapAlbumsVibeTab();
      await searchPage.scrollVibeDetailDown();
      await searchPage.scrollVibeDetailUp();

      await searchPage.tapAllVibeTab();
      await searchPage.scrollVibeDetailDown();
      await searchPage.scrollVibeDetailUp();

      expect(searchPage.isVibePageScreenVisible(), true);
    });

    await tryTest('TC-SEARCH-006 | Back from vibe detail to main search screen', () async {
      await searchPage.GenreBackButton();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(searchPage.isSearchScreenVisible(), true);
    });

    await tryTest('TC-SEARCH-007 | Suggestion list appears when typing in search bar', () async {
      await searchPage.tapSearchBar();
      await searchPage.typeQuery('A');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(searchPage.isSuggestionListVisible(), true,
          reason: 'Typing "A" should surface a suggestion list');
    });

    await tryTest('TC-SEARCH-008 | No results message appears for unlikely query', () async {
      await searchPage.typeQuery('zhsyg');
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(searchPage.isNoResultsVisible(), true,
          reason: 'Typing "zhsyg" should show "No results found" in suggestions');
    });

    await tryTest('TC-SEARCH-009 | Search "Yo" and navigate to results screen', () async {
      await searchPage.typeQuery('Yo');
      await searchPage.submitSearch();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(searchPage.isResultsScreenVisible(), true,
          reason: 'Searching "Yo" should navigate to the results screen');
    });
  
    await tryTest('TC-SEARCH-010 | Scroll results down and up', () async {
      await searchPage.scrollResultsDown();
      await searchPage.scrollResultsUp();
      expect(searchPage.isResultsScreenVisible(), true);
    });

    await tryTest('TC-SEARCH-011 | Play a track from results and show mini player', () async {
      await searchPage.tapFirstTrackInResults();
      // pump instead of pumpAndSettle — audio playback prevents the frame loop from settling
      await tester.pump(const Duration(seconds: 2));
      expect(searchPage.isMiniPlayerVisible(), true,
          reason: 'Mini player should appear after playing a track');
    });

    await tryTest('TC-SEARCH-012/013 | Switch result tabs', () async {
      await searchPage.tapTracksResultsTab();
      await searchPage.tapProfilesResultsTab();
      await searchPage.tapPlaylistsResultsTab();
      await searchPage.tapAlbumsResultsTab();
      await searchPage.scrollHorizontallyInSection(searchTabBar);
      await searchPage.tapAllResultsTab();

      // ─── TC-SEARCH-013 | Switch result tabs by swiping horizontally ──────
      await searchPage.swipeResultsRight();  // Albums → Playlists
      await searchPage.swipeResultsLeft();   // Playlists → Albums
      await searchPage.swipeResultsLeft();   // All → Tracks
      await searchPage.swipeResultsLeft();   // Tracks → Profiles
      await searchPage.swipeResultsLeft();   // Profiles → Playlists
      expect(searchPage.isResultsScreenVisible(), true);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    await tryTest('TC-SEARCH-014 | Clear search and return to main search screen', () async {
      await searchPage.clearSearch();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(searchPage.isSearchScreenVisible(), true,
          reason: 'Clearing search should return to the vibes screen');
    });

    await searchPage.pausePlayback();

    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}