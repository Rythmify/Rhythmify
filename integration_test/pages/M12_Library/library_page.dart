import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class LibraryPage extends BasePage {
  LibraryPage(WidgetTester tester) : super(tester);

  // ── Navigation ─────────────────────────────────────────────────────────────
  // TODO: pending cross-team Key() implementation
  Future<void> tapLibraryNavButton() async => await tapByKey(libraryNavButton);

  // ── Library main screen sections ───────────────────────────────────────────
  // TODO: pending cross-team Key() implementation
  Future<void> tapYourLikes()             async => await tapByKey(libraryYourLikes);
  Future<void> tapAlbums()                async => await tapByKey(libraryAlbums);
  Future<void> tapFollowing()             async => await tapByKey(libraryFollowing);
  Future<void> tapStations()              async => await tapByKey(libraryStations);
  Future<void> tapYourInsights()          async => await tapByKey(libraryYourInsights);
  Future<void> tapYourUploads()           async => await tapByKey(libraryYourUploads);
  Future<void> tapRecentlyPlayedSeeAll()  async => await tapByKey(libraryRecentlyPlayedSeeAll);

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

  // TODO: pending cross-team — three-dots key per track item
  Future<void> tapFirstTrackThreeDots() async => await tapByKey(libraryLikesFirstTrackThreeDots);
  // TODO: pending cross-team — unlike option inside the bottom sheet
  Future<void> tapUnlikeOption()         async => await tapByKey(libraryLikesUnlikeOption);

  bool isLikesScreenVisible()            => isVisible(libraryLikesScrollView);
  bool isTrackVisible(String trackName)  => find.text(trackName).evaluate().isNotEmpty;

  // ── Albums ─────────────────────────────────────────────────────────────────
  Future<void> tapAlbumsBack()   async => await tapByKey(libraryAlbumsBackButton);

  Future<void> typeInAlbumsSearch(String query) async {
    await enterTextByKey(libraryAlbumsSearchField, query);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // TODO: pending cross-team — first album card key & album scroll view
  Future<void> tapFirstAlbum()   async => await tapByKey(libraryAlbumsFirstItem);
  Future<void> tapAlbumPlay()    async => await tapByKey(libraryAlbumsPlayButton);

  bool isAlbumsScreenVisible()      => isVisible(libraryAlbumsBackButton);
  bool isAlbumDetailVisible()       => isVisible(libraryAlbumDetailScreen);
  bool isNoResultsMessageVisible(String query) =>
      find.text('No results for "$query"').evaluate().isNotEmpty;

  // ── Following ──────────────────────────────────────────────────────────────
  // TODO: pending cross-team — following back button key
  Future<void> tapFollowingBack()          async => await tapByKey(libraryFollowingBackButton);
  Future<void> tapFirstFollowingButton()   async => await tapByKey(libraryFollowingFirstButton);
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

  // TODO: pending cross-team — first station card key, scroll view, play button, detail screen
  Future<void> tapFirstStation()  async => await tapByKey(libraryStationsFirstItem);
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

  // TODO: pending cross-team — three-dots key per upload item & delete option
  Future<void> tapFirstUploadThreeDots() async => await tapByKey(uploadsFirstTrackThreeDots);
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