import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class LibraryPage extends BasePage {
  LibraryPage(WidgetTester tester) : super(tester);

  // ── Navigation ─────────────────────────────────────────────────────────────
  Future<void> tapLibraryNavButton() async => await tapByKey(libraryNavButton);

  // ── Library main screen sections ───────────────────────────────────────────
  Future<void> tapYourLikes()             async => await tapByKey(libraryLikesItem);
  Future<void> tapAlbums()                async => await tapByKey(libraryAlbumsItem);
  Future<void> tapFollowing()             async => await tapByKey( libraryFollowingItem);
  Future<void> tapStations()              async => await tapByKey(libraryStationsItem);
  Future<void> tapYourInsights()          async => await tapByKey(libraryInsightsItem);
  Future<void> tapYourUploads()           async => await tapByKey(libraryUploadsItem);
  Future<void> tapRecentlyPlayedSeeAll()  async => await tapByKey(libraryRecentlyPlayedSeeAllButton);

  // ── Generic scroll helpers ─────────────────────────────────────────────────
  Future<void> scrollListDown(String scrollableKey) async {
    await tester.drag(find.byKey(Key(scrollableKey)), const Offset(0, -400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> scrollListUp(String scrollableKey) async {
    await tester.drag(find.byKey(Key(scrollableKey)), const Offset(0, 400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  // ── Your Likes ─────────────────────────────────────────────────────────────
  Future<void> tapLikesBack()        async => await tapByKey(libraryLikesBackButton);
  Future<void> tapLikesPlay()        async => await tapByKey(libraryLikesPlayButton);
  Future<void> tapLikesShuffle()     async => await tapByKey(libraryLikesShuffleButton);

  Future<void> typeInLikesSearch(String query) async {
    await enterTextByKey(libraryLikesSearchBar, query);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // Finds the first "more" inkwell in the likes list and taps it
  Future<void> tapFirstTrackThreeDots() async {
    final moreFinder = find.byWidgetPredicate(
      (widget) =>
          widget is InkWell &&
          widget.key != null &&
          widget.key.toString().contains('track_card_') &&
          widget.key.toString().contains('_more_inkwell'),
    );
    await tester.tap(moreFinder.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> tapUnlikeOption()         async => await tapByKey(trackLikeInkwell);
  bool isLikesScreenVisible()            => isVisible(libraryLikesScrollView);
  bool isTrackVisible(String trackName)  => find.text(trackName).evaluate().isNotEmpty;

  // ── Albums ─────────────────────────────────────────────────────────────────
  Future<void> tapAlbumsBack()   async => await tapByKey(libraryAlbumsBackButton);

  Future<void> typeInAlbumsSearch(String query) async {
    await enterTextByKey(libraryAlbumsSearchField, query);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> tapFirstAlbum() async {
    final finder = find.byWidgetPredicate(
      (widget) =>
          widget is InkWell &&
          widget.key != null &&
          widget.key.toString().contains('album_tile_') &&
          widget.key.toString().contains('_inkwell'),
    );
    await tester.tap(finder.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }
  Future<void> tapAlbumPlay()    async => await tapByKey(libraryAlbumsPlayButton);

  bool isAlbumsScreenVisible()      => isVisible(libraryAlbumsBackButton);
  bool isAlbumDetailVisible()       => isVisible(libraryAlbumDetailScreen);
  bool isNoResultsMessageVisible(String query) =>
      find.text('No results for "$query"').evaluate().isNotEmpty;

  // ── Following ──────────────────────────────────────────────────────────────
  Future<void> tapFollowingBack()        async => await tapByKey(libraryFollowingBackButton);

  Future<void> tapFirstFollowingButton() async {
    final finder = find.byWidgetPredicate(
      (widget) =>
          widget is OutlinedButton &&
          widget.key != null &&
          widget.key.toString().contains('following_item_') &&
          widget.key.toString().contains('_following_button'),
    );
    await tester.tap(finder.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }
  Future<void> tapCancelOnDialog()         async => await tapByKey(libraryFollowingDialogCancel);
  Future<void> tapUnfollowOnDialog()       async => await tapByKey(libraryFollowingDialogUnfollow);

  bool isFollowingScreenVisible()  => isVisible(followingListView);
  bool isUnfollowDialogVisible()   => isVisible(libraryFollowingUnfollowDialog);

  // ── Stations ───────────────────────────────────────────────────────────────
  Future<void> tapStationsBack() async => await tapByKey(libraryStationsBackButton);

  Future<void> typeInStationsSearch(String query) async {
    await enterTextByKey(libraryStationsSearchField, query);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> tapFirstStation() async {
    final finder = find.byWidgetPredicate(
      (widget) =>
          widget is InkWell &&
          widget.key != null &&
          widget.key.toString().contains('station_tile_') &&
          widget.key.toString().contains('_inkwell'),
    );
    await tester.tap(finder.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }
  Future<void> tapStationPlay()   async => await tapByKey(libraryStationsPlayButton);

  bool isStationsScreenVisible()      => isVisible(libraryStationsBackButton);
  bool isStationDetailVisible()       => isVisible(libraryStationDetailScreen);

  // ── Your Insights ──────────────────────────────────────────────────────────
  Future<void> tapAllPlatformsTab() async => await tapByKey(insightsAllPlatformsTab);

  Future<void> scrollInsightsDown() async {
    await tester.drag(find.byKey(const Key(insightsScDataListView)), const Offset(0, -400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> scrollInsightsUp() async {
    await tester.drag(find.byKey(const Key(insightsScDataListView)), const Offset(0, 400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  // TODO: pending cross-team — insights back button & insights screen key
  Future<void> tapInsightsBack() async => await tapByKey(libraryInsightsBackButton);

  bool isInsightsScreenVisible() => isVisible(insightsSummaryCard);
  bool isInsightsStatsVisible()  =>
      isVisible(insightsTotalPlaysStat) &&
      isVisible(insightsTotalListenersStat) &&
      isVisible(insightsTotalLikesStat);

  // ── Your Uploads ───────────────────────────────────────────────────────────
  Future<void> tapUploadsBack()    async => await tapByKey(uploadsBackButton);
  Future<void> tapFirstUploadPlay() async => await tapByKey(uploadsPlayButton);

  Future<void> typeInUploadsSearch(String query) async {
    await enterTextByKey(uploadsSearchBar, query);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> tapFirstUploadThreeDots() async {
    final finder = find.byWidgetPredicate(
      (widget) =>
          widget is InkWell &&
          widget.key != null &&
          widget.key.toString().contains('track_card_') &&
          widget.key.toString().contains('_more_inkwell'),
    );
    await tester.tap(finder.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }
  Future<void> tapDeleteUploadOption()   async => await tapByKey(uploadsDeleteOption);

  bool isUploadsScreenVisible() => isVisible(uploadsScrollView);

  // ── Recently Played ────────────────────────────────────────────────────────
  Future<void> tapHistoryPlay()         async => await tapByKey(historyPlayAllFab);
  Future<void> tapDeleteHistoryIcon()   async => await tapByKey(historyClearIconButton);
  Future<void> tapCancelClearDialog()   async => await tapByKey(libraryRecentlyPlayedDialogCancel);
  Future<void> tapClearOnDialog()       async => await tapByKey(libraryRecentlyPlayedDialogClear);

  // TODO: pending cross-team — history back button & history screen key
  Future<void> tapHistoryBack()         async => await tapByKey(libraryHistoryBackButton);

  bool isRecentlyPlayedScreenVisible()  => isVisible(historyListView);
  bool isNoListeningHistoryVisible()    =>
      find.text('No listening history').evaluate().isNotEmpty;
}