import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class SearchPage extends BasePage {
  SearchPage(WidgetTester tester) : super(tester);

  // ── Navigation ─────────────────────────────────────────────────────────────
  // TODO: replace key when cross-team implements it
  Future<void> tapSearchNavButton() async => await tapByKey(searchNavButton);
  Future<void> tapBack() async => await tapByKey(searchBackButton);

  // ── Search bar ─────────────────────────────────────────────────────────────
  Future<void> tapSearchBar() async => await tapByKey(searchBarField);

  Future<void> typeQuery(String query) async {
    await enterTextByKey(searchBarField, query);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> clearSearch() async => await tapByKey(searchBarClearButton);

  Future<void> submitSearch() async {
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  // ── Vibes section ──────────────────────────────────────────────────────────
  Future<void> scrollVibesDown() async {
    await tester.drag(find.byKey(const Key(vibesGrid)), const Offset(0, -400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> scrollVibesUp() async {
    await tester.drag(find.byKey(const Key(vibesGrid)), const Offset(0, 400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> tapVibeCard(String vibeName) async {
    await tester.tap(find.text(vibeName));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // ── Vibe detail — inner tab bar (All / Trending / Playlists / Albums) ──────
  // TODO: replace keys when cross-team implements them
  Future<void> tapAllVibeTab() async => await tapByKey(searchVibeTabAll);
  Future<void> tapTrendingVibeTab() async => await tapByKey(searchVibeTabTrending);
  Future<void> tapPlaylistsVibeTab() async => await tapByKey(searchVibeTabPlaylists);
  Future<void> tapAlbumsVibeTab() async => await tapByKey(searchVibeTabAlbums);

  Future<void> scrollVibeDetailDown() async {
    await tester.drag(find.byKey(const Key(searchVibeDetailScrollView)), const Offset(0, -400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> scrollVibeDetailUp() async {
    await tester.drag(find.byKey(const Key(searchVibeDetailScrollView)), const Offset(0, 400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> swipeVibeDetailLeft() async {
    await tester.drag(find.byKey(const Key(searchVibeDetailPageView)), const Offset(-300, 0));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> swipeVibeDetailRight() async {
    await tester.drag(find.byKey(const Key(searchVibeDetailPageView)), const Offset(300, 0));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  // ── Search results — tab bar (All / Tracks / Profiles / Playlists / Albums) ─
  Future<void> tapAllResultsTab() async => await tapByKey(searchResultsTabAll);
  Future<void> tapTracksResultsTab() async => await tapByKey(searchResultsTabTracks);
  Future<void> tapProfilesResultsTab() async => await tapByKey(searchResultsTabProfiles);
  Future<void> tapPlaylistsResultsTab() async => await tapByKey(searchResultsTabPlaylists);
  Future<void> tapAlbumsResultsTab() async => await tapByKey(searchResultsTabAlbums);

  Future<void> swipeResultsLeft() async {
    await tester.drag(find.byKey(const Key(searchResultsPageView)), const Offset(-300, 0));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> swipeResultsRight() async {
    await tester.drag(find.byKey(const Key(searchResultsPageView)), const Offset(300, 0));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> scrollResultsDown() async {
    await tester.drag(find.byKey(const Key(searchResultsScrollView)), const Offset(0, -400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> scrollResultsUp() async {
    await tester.drag(find.byKey(const Key(searchResultsScrollView)), const Offset(0, 400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  // TODO: replace key when cross-team implements it
  Future<void> tapFirstTrackInResults() async => await tapByKey(searchFirstTrackPlayButton);

  // ── Visibility checks ──────────────────────────────────────────────────────
  bool isSearchScreenVisible()     => isVisible(searchScreen);
  bool isSuggestionListVisible()   => isVisible(searchSuggestionsList);
  bool isNoResultsVisible()        => find.text('No results found').evaluate().isNotEmpty;
  // TODO: replace keys when cross-team implements them
  bool isVibeDetailScreenVisible() => isVisible(searchVibeDetailScreenKey);
  bool isResultsScreenVisible()    => isVisible(searchResultsScreenKey);
  bool isMiniPlayerVisible()       => isVisible(searchMiniPlayerBar);
}