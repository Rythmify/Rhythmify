import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M12_Library/library_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M - Library - all scenarios', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ── Login ────────────────────────────────────────────────────────────────
    final loginPage   = LoginPage(tester);
    final libraryPage = LibraryPage(tester);

    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(loginPage.isOnHomePage(), true);

    // ─── TC-LIBRARY-001 | Navigate to Library tab ─────────────────────────
    await libraryPage.tapLibraryNavButton();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ════════════════════════════════════════════════════════════════════════
    // YOUR LIKES
    // ════════════════════════════════════════════════════════════════════════

    // ─── TC-LIBRARY-002 | Open Your Likes ────────────────────────────────
    await libraryPage.tapYourLikes();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isLikesScreenVisible(), true);

    // ─── TC-LIBRARY-003 | Play button is tappable ────────────────────────
    await libraryPage.tapLikesPlay();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ─── TC-LIBRARY-004 | Scroll likes list down and up ──────────────────
    await libraryPage.scrollListDown(libraryLikesScrollView);
    await libraryPage.scrollListUp(libraryLikesScrollView);

    // ─── TC-LIBRARY-005 | Three-dots → Unlike a track ────────────────────
    await libraryPage.tapFirstTrackThreeDots();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await libraryPage.tapUnlikeOption();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ─── TC-LIBRARY-006 | Search for liked track → visible ───────────────
    await libraryPage.typeInLikesSearch("Happy");
    expect(libraryPage.isTrackVisible("Happy"), true,
        reason: 'Liked track should appear in search results');

    // ─── TC-LIBRARY-007 | Search for unliked track → not visible ─────────
    await libraryPage.typeInLikesSearch("Unliked Track");
    expect(libraryPage.isTrackVisible("Unliked Track"), false,
        reason: 'Unliked track should not appear in likes search');

    // ─── TC-LIBRARY-008 | Back to Library ────────────────────────────────
    await libraryPage.tapLikesBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ════════════════════════════════════════════════════════════════════════
    // ALBUMS
    // ════════════════════════════════════════════════════════════════════════

    // ─── TC-LIBRARY-009 | Open Albums ────────────────────────────────────
    await libraryPage.tapAlbums();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isAlbumsScreenVisible(), true);

    // ─── TC-LIBRARY-010 | Scroll albums list down and up ─────────────────
    await libraryPage.scrollListDown(libraryAlbumsScrollView);
    await libraryPage.scrollListUp(libraryAlbumsScrollView);

    // ─── TC-LIBRARY-011 | Open an album ──────────────────────────────────
    await libraryPage.tapFirstAlbum();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isAlbumDetailVisible(), true);

    // ─── TC-LIBRARY-012 | Play the album ─────────────────────────────────
    await libraryPage.tapAlbumPlay();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ─── TC-LIBRARY-013 | Back to Albums list ────────────────────────────
    await libraryPage.tapAlbumsBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isAlbumsScreenVisible(), true);

    // ─── TC-LIBRARY-014 | Search for existing album → visible ────────────
    await libraryPage.typeInAlbumsSearch('Quran');
    expect(libraryPage.isTrackVisible('Quran'), true,
        reason: 'Saved album should appear in search');

    // ─── TC-LIBRARY-015 | Search for non-existing album → no results ─────
    await libraryPage.typeInAlbumsSearch('notSavedAlbumName');
    expect(libraryPage.isNoResultsMessageVisible('notSavedAlbumName'), true,
        reason: '"No results for" message should appear');

    // ─── TC-LIBRARY-016 | Back to Library ────────────────────────────────
    await libraryPage.tapAlbumsBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ════════════════════════════════════════════════════════════════════════
    // FOLLOWING
    // ════════════════════════════════════════════════════════════════════════

    // ─── TC-LIBRARY-017 | Open Following ─────────────────────────────────
    await libraryPage.tapFollowing();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isFollowingScreenVisible(), true);

    // ─── TC-LIBRARY-018 | Scroll following list down and up ──────────────
    await libraryPage.scrollListDown(followingListView);
    await libraryPage.scrollListUp(followingListView);

    // ─── TC-LIBRARY-019 | Tap Following button → dialog appears ──────────
    await libraryPage.tapFirstFollowingButton();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(libraryPage.isUnfollowDialogVisible(), true);

    // ─── TC-LIBRARY-020 | Tap Cancel → dialog dismisses ──────────────────
    await libraryPage.tapCancelOnDialog();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(libraryPage.isUnfollowDialogVisible(), false,
        reason: 'Dialog should dismiss on Cancel');

    // ─── TC-LIBRARY-021 | Tap Following again → tap Unfollow ─────────────
    await libraryPage.tapFirstFollowingButton();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(libraryPage.isUnfollowDialogVisible(), true);
    await libraryPage.tapUnfollowOnDialog();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ─── TC-LIBRARY-022 | Back to Library ────────────────────────────────
    await libraryPage.tapFollowingBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ════════════════════════════════════════════════════════════════════════
    // STATIONS
    // ════════════════════════════════════════════════════════════════════════

    // ─── TC-LIBRARY-023 | Open Stations ──────────────────────────────────
    await libraryPage.tapStations();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isStationsScreenVisible(), true);

    // ─── TC-LIBRARY-024 | Scroll stations list down and up ────────────────
    await libraryPage.scrollListDown(libraryStationsScrollView);
    await libraryPage.scrollListUp(libraryStationsScrollView);

    // ─── TC-LIBRARY-025 | Open a station ─────────────────────────────────
    await libraryPage.tapFirstStation();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isStationDetailVisible(), true);

    // ─── TC-LIBRARY-026 | Play the station ───────────────────────────────
    await libraryPage.tapStationPlay();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ─── TC-LIBRARY-027 | Back to Stations list ──────────────────────────
    await libraryPage.tapStationsBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isStationsScreenVisible(), true);

    // ─── TC-LIBRARY-028 | Search for existing station → visible ──────────
    await libraryPage.typeInStationsSearch("savedStationName");   //to be replaced
    expect(libraryPage.isTrackVisible("savedStationName"), true,
        reason: 'Saved station should appear in search');

    // ─── TC-LIBRARY-029 | Search for non-existing station → no results ────
    await libraryPage.typeInStationsSearch("notSavedStationName");
    expect(libraryPage.isNoResultsMessageVisible("notSavedStationName"), true,
        reason: '"No results for" message should appear');

    // ─── TC-LIBRARY-030 | Back to Library ────────────────────────────────
    await libraryPage.tapStationsBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ════════════════════════════════════════════════════════════════════════
    // YOUR INSIGHTS
    // ════════════════════════════════════════════════════════════════════════

    // ─── TC-LIBRARY-031 | Open Your Insights ─────────────────────────────
    await libraryPage.tapYourInsights();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isInsightsScreenVisible(), true);

    // ─── TC-LIBRARY-032 | Plays / Listeners / Likes stats are visible ─────
    expect(libraryPage.isInsightsStatsVisible(), true,
        reason: 'All 3 stat counters should be visible');

    // ─── TC-LIBRARY-033 | Scroll insights down and up ────────────────────
    await libraryPage.scrollInsightsDown();
    await libraryPage.scrollInsightsUp();

    // ─── TC-LIBRARY-034 | All Platforms tab is tappable ──────────────────
    await libraryPage.tapAllPlatformsTab();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(libraryPage.isInsightsScreenVisible(), true);

    // ─── TC-LIBRARY-035 | Back to Library ────────────────────────────────
    await libraryPage.tapInsightsBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ════════════════════════════════════════════════════════════════════════
    // YOUR UPLOADS
    // ════════════════════════════════════════════════════════════════════════

    // ─── TC-LIBRARY-036 | Open Your Uploads ──────────────────────────────
    await libraryPage.tapYourUploads();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isUploadsScreenVisible(), true);

    // ─── TC-LIBRARY-037 | Play a track ───────────────────────────────────
    await libraryPage.tapFirstUploadPlay();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ─── TC-LIBRARY-038 | Three-dots → Delete uploaded track ─────────────
    await libraryPage.tapFirstUploadThreeDots();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await libraryPage.tapDeleteUploadOption();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ─── TC-LIBRARY-039 | Scroll uploads list down and up ────────────────
    await libraryPage.scrollListDown(uploadsScrollView);
    await libraryPage.scrollListUp(uploadsScrollView);

    // ─── TC-LIBRARY-040 | Search for uploaded track → visible ────────────
    await libraryPage.typeInUploadsSearch("أنا وأخي");
    expect(libraryPage.isTrackVisible("أنا وأخي"), true,
        reason: 'Uploaded track should appear in search');

    // ─── TC-LIBRARY-041 | Search for non-uploaded track → not visible ─────
    await libraryPage.typeInUploadsSearch("notUploadedTrackName");
    expect(libraryPage.isTrackVisible("notUploadedTrackName"), false,
        reason: 'Non-uploaded track should not appear');

    // ─── TC-LIBRARY-042 | Back to Library ────────────────────────────────
    await libraryPage.tapUploadsBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ════════════════════════════════════════════════════════════════════════
    // RECENTLY PLAYED
    // ════════════════════════════════════════════════════════════════════════

    // ─── TC-LIBRARY-043 | Tap See All → Recently Played screen ───────────
    await libraryPage.tapRecentlyPlayedSeeAll();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isRecentlyPlayedScreenVisible(), true);

    // ─── TC-LIBRARY-044 | Play a track from history ───────────────────────
    await libraryPage.tapHistoryPlay();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // ─── TC-LIBRARY-045 | Scroll history list down and up ─────────────────
    await libraryPage.scrollListDown(historyListView);
    await libraryPage.scrollListUp(historyListView);

    // ─── TC-LIBRARY-046 | Delete icon → dialog → tap Cancel → list intact ─
    await libraryPage.tapDeleteHistoryIcon();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await libraryPage.tapCancelClearDialog();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(libraryPage.isRecentlyPlayedScreenVisible(), true,
        reason: 'History list should remain after Cancel');

    // ─── TC-LIBRARY-047 | Delete icon → dialog → tap Clear → history gone ─
    await libraryPage.tapDeleteHistoryIcon();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await libraryPage.tapClearOnDialog();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(libraryPage.isNoListeningHistoryVisible(), true,
        reason: '"No listening history" should appear after clearing');

    // ─── TC-LIBRARY-048 | Back to Library ────────────────────────────────
    await libraryPage.tapHistoryBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}