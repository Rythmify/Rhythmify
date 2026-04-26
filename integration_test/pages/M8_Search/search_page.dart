import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class SearchPage extends BasePage {
  SearchPage(WidgetTester tester) : super(tester);

  // ── Navigation ─────────────────────────────────────────────────────────────
  Future<void> tapSearchNavButton() async => await tapByKey(searchNavButton);
  //Future<void> tapBack() async => await tapByKey(searchBackButton);

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
    await tester.drag(find.byKey(const Key(vibesList)), const Offset(0, -400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> scrollVibesUp() async {
    await tester.drag(find.byKey(const Key(vibesList)), const Offset(0, 400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> tapVibeCard(String vibeName) async {
    await tester.tap(find.text(vibeName));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // ── Vibe detail — inner tab bar (All / Trending / Playlists / Albums) ──────
  Future<void> tapAllVibeTab() async => await tapByKey(genreTabAll);
  Future<void> tapTrendingVibeTab() async => await tapByKey(genreTabTrending);
  Future<void> tapPlaylistsVibeTab() async => await tapByKey(genreTabPlaylists);
  Future<void> tapAlbumsVibeTab() async => await tapByKey(genreTabAlbums);

  Future<void> scrollVibeDetailDown() async {
    await tester.drag(find.byKey(const Key(genrePage)), const Offset(0, -400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> scrollVibeDetailUp() async {
    await tester.drag(find.byKey(const Key(genrePage)), const Offset(0, 400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> swipeVibeDetailLeft() async {
    await tester.drag(find.byKey(const Key(genrePage)), const Offset(-300, 0));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> swipeVibeDetailRight() async {
    await tester.drag(find.byKey(const Key(genrePage)), const Offset(300, 0));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> GenreBackButton() async => await tapByKey(genreBackButton);

  // ── Search results — tab bar (All / Tracks / Profiles / Playlists / Albums) ─
  Future<void> tapAllResultsTab() async => await tapByKey(searchTabAll);
  Future<void> tapTracksResultsTab() async => await tapByKey(searchTabTracks);
  Future<void> tapProfilesResultsTab() async => await tapByKey(searchTabProfiles);
  Future<void> tapPlaylistsResultsTab() async => await tapByKey(searchTabPlaylists);
  Future<void> tapAlbumsResultsTab() async => await tapByKey(searchTabAlbums);

  Future<void> swipeResultsLeft() async {
    await tester.drag(find.byKey(const Key(searchTabView)), const Offset(-300, 0));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> swipeResultsRight() async {
    await tester.drag(find.byKey(const Key(searchTabView)), const Offset(300, 0));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> scrollResultsDown() async {
    await tester.drag(find.byKey(const Key(searchTabView)), const Offset(0, -400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> scrollResultsUp() async {
    await tester.drag(find.byKey(const Key(searchTabView)), const Offset(0, 400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  // TODO: replace key when cross-team implements it
  Future<void> tapFirstTrackInResults() async => await tapByKey(searchFirstTrackPlayButton);

  // ── Visibility checks ──────────────────────────────────────────────────────
  bool isSearchScreenVisible()     => isVisible(searchScreen);
  bool isSuggestionListVisible()   => isVisible(searchSuggestionsList);
  bool isNoResultsVisible()        => find.text('No results found').evaluate().isNotEmpty;
  
  bool isVibePageScreenVisible() => isVisible(genrePage);
  bool isResultsScreenVisible()    => isVisible(searchTabView);
  // TODO: replace keys when cross-team implements them
  bool isMiniPlayerVisible()       => isVisible(searchMiniPlayerBar);
}