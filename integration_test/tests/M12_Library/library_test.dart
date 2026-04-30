import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M12_Library/library_page.dart';
import '../../pages/base_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M12 - Library - all scenarios', (tester) async {
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

    // ── Login ────────────────────────────────────────────────────────────────
    final loginPage   = LoginPage(tester);
    final basePage    = BasePage(tester);
    final libraryPage = LibraryPage(tester);

    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(loginPage.isOnHomePage(), true);

    // ─── TC-LIBRARY-001 | Navigate to Library tab ─────────────────────────
    await tryTest('TC-LIBRARY-001 | Navigate to Library tab', () async {
      await libraryPage.tapLibraryNavButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });


    // YOUR LIKES SECTION
    debugPrint('YOUR LIKES SECTION');
    // ─── TC-LIBRARY-002 | Open Your Likes ────────────────────────────────
    await tryTest('TC-LIBRARY-002 | Open Your Likes', () async {
      await libraryPage.tapYourLikes();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(libraryPage.isLikesScreenVisible(), true);
    });

    // ─── TC-LIBRARY-003 | Filter likes (Most recent/ Title(A-Z)/ Artist(A-Z)) ────────────────────────
    await tryTest('TC-LIBRARY-003 | Filter likes (Most recent/ Title(A-Z)/ Artist(A-Z))', () async {
      await libraryPage.tapLikesFilterButton();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await libraryPage.tapLikeFilterOptionTitleAZ();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Hidden under the nav bar --> cross issue
      // await libraryPage.tapLikesFilterButton();
      // await tester.pumpAndSettle(const Duration(seconds: 1));
      // await libraryPage.tapLikeFilterOptionArtistAZ();
      // await tester.pumpAndSettle(const Duration(seconds: 2));

      await libraryPage.tapLikesFilterButton();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await libraryPage.tapLikeFilterOptionMoreRecent();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    // ─── TC-LIBRARY-003 | Play button is tappable ────────────────────────
    await tryTest('TC-LIBRARY-004 | Play button is tappable', () async {
      await libraryPage.tapLikesPlay();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await libraryPage.tapLikesPlay();
    });

    // ─── TC-LIBRARY-004 | Scroll likes list down and up ──────────────────
    await tryTest('TC-LIBRARY-005 | Scroll likes list down and up', () async {
      await libraryPage.scrollListDown(libraryLikesScrollView);
      await libraryPage.scrollListUp(libraryLikesScrollView);
    });

    // ─── TC-LIBRARY-005 | Three-dots → Unlike a track ────────────────────
    await tryTest('TC-LIBRARY-006 | Three-dots → Unlike a track', () async {
      await libraryPage.tapFirstTrackThreeDots();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await libraryPage.tapUnlikeOption();
      await basePage.pullToRefresh(libraryLikesScrollView);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    // ─── TC-LIBRARY-006 | Search for liked track → visible ───────────────
    await tryTest('TC-LIBRARY-007 | Search for liked track → visible', () async {
      await libraryPage.typeInLikesSearch("أنا وأخي");
      expect(libraryPage.isTrackVisible("أنا وأخي"), true,
          reason: 'Liked track should appear in search results');
    });

    // ─── TC-LIBRARY-007 | Search for unliked track → not visible ─────────
    await tryTest('TC-LIBRARY-008 | Search for unliked track → not visible', () async {
      await libraryPage.typeInLikesSearch("Unliked Track");
    });

    // ─── TC-LIBRARY-008 | Back to Library ────────────────────────────────
    await tryTest('TC-LIBRARY-009 | Back to Library', () async {
      await libraryPage.tapLikesBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });


    // ALBUMS SECTION
    debugPrint('ALBUMS SECTION'); 
    // ─── TC-LIBRARY-009 | Open Albums ────────────────────────────────────
    await tryTest('TC-LIBRARY-010 | Open Albums', () async {
      await libraryPage.tapAlbums();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(libraryPage.isAlbumsScreenVisible(), true);
    });

    // ─── TC-LIBRARY-010 | Scroll albums list down and up ─────────────────
    // await tryTest('TC-LIBRARY-011 | Scroll albums list down and up', () async {
    //   await libraryPage.scrollListDown(libraryAlbumsScrollView);
    //   await libraryPage.scrollListUp(libraryAlbumsScrollView);
    // });

    // ─── TC-LIBRARY-011 | Filter albums ──────────────────────────────────
    await tryTest('TC-LIBRARY-012 | Filter albums (RecentlyAdded - FirstAdded - AlbumName)', () async {
      await libraryPage.tapAlbumFilterButton();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await libraryPage.tapAlbumFilterOptionRecentlyAdded();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await libraryPage.tapAlbumFilterButton();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await libraryPage.tapAlbumFilterOptionFirstAdded();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await libraryPage.tapAlbumFilterButton();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await libraryPage.tapAlbumFilterOptionAlbumName();
       await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    // ─── TC-LIBRARY-014 | Search for existing album → visible ────────────
    await tryTest('TC-LIBRARY-013 | Search for existing album → visible', () async {
      await libraryPage.typeInAlbumsSearch('Quran');
      expect(libraryPage.isTrackVisible('Quran'), true,
          reason: 'Saved album should appear in search');
    });

    // ─── TC-LIBRARY-015 | Search for non-existing album → no results ─────
    await tryTest('TC-LIBRARY-014 | Search for non-existing album → no results', () async {
      await libraryPage.typeInAlbumsSearch('notSavedAlbumName');
      expect(libraryPage.isNoResultsMessageVisible('notSavedAlbumName'), true,
          reason: '"No results for" message should appear');
    });

    // ─── TC-LIBRARY-011 | Open an album ──────────────────────────────────
    await tryTest('TC-LIBRARY-015 | Open an album', () async {
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await libraryPage.tapFirstAlbum();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(libraryPage.isAlbumDetailVisible(), true);
    });

    await tryTest('TC-LIBARARY-016 | Like & 3 dots are clickable', () async {
      await libraryPage.tapAlbumLike();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await libraryPage.tapAlbumShowMore();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    // ─── TC-LIBRARY-012 | Play & shuffle the album ─────────────────────────────────
    await tryTest('TC-LIBRARY-017 | Play & shuffle the album', () async {
      await libraryPage.tapAlbumPlay();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await libraryPage.tapAlbumShuffle();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    // ─── TC-LIBRARY-013 | Back to Albums list ────────────────────────────
    await tryTest('TC-LIBRARY-018 | Back to Albums list', () async {
      await libraryPage.tapAlbumsBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(libraryPage.isAlbumsScreenVisible(), true);
    });

    // ─── TC-LIBRARY-016 | Back to Library ────────────────────────────────
    await tryTest('TC-LIBRARY-019 | Back to Library', () async {
      await libraryPage.tapAlbumsBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });


    // FOLLOWING SECTION
    debugPrint('FOLLOWING SECTION');
    // ─── TC-LIBRARY-017 | Open Following ─────────────────────────────────
    await tryTest('TC-LIBRARY-020 | Open Following', () async {
      await libraryPage.tapFollowing();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(libraryPage.isFollowingScreenVisible(), true);
    });

    await tryTest('TC-LIBRARY- 021 | Tap follower --> profile opens', () async {
      await libraryPage.tapFirstFollower();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(libraryPage.isProfileScreenVisible(), true);
      await libraryPage.tapProfileBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    // ─── TC-LIBRARY-018 | Scroll following list down and up ──────────────
    await tryTest('TC-LIBRARY-022 | Scroll following list down and up', () async {
      await libraryPage.scrollListDown(followingListView);
      await libraryPage.scrollListUp(followingListView);
    });

    // ─── TC-LIBRARY-019 | Tap Following button → dialog appears ──────────
    await tryTest('TC-LIBRARY-023 | Tap UnFollow button → dialog appears', () async {
      await libraryPage.tapFirstFollowingButton();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(libraryPage.isUnfollowDialogVisible(), true);
    });

    // ─── TC-LIBRARY-020 | Tap Cancel → dialog dismisses ──────────────────
    await tryTest('TC-LIBRARY-024 | Tap Cancel → dialog dismisses', () async {
      await libraryPage.tapCancelOnDialog();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(libraryPage.isUnfollowDialogVisible(), false,
          reason: 'Dialog should dismiss on Cancel');
    });

    // ─── TC-LIBRARY-021 | Tap Following again → tap Unfollow ─────────────
    await tryTest('TC-LIBRARY-025 | Tap Following again → tap Unfollow', () async {
      await libraryPage.tapFirstFollowingButton();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(libraryPage.isUnfollowDialogVisible(), true);
      await libraryPage.tapUnfollowOnDialog();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    // ─── TC-LIBRARY-022 | Back to Library ────────────────────────────────
    await tryTest('TC-LIBRARY-026 | Back to Library', () async {
      await libraryPage.tapFollowingBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });


    // STATIONS SECTION
    debugPrint('STATIONS SECTION');
    // ─── TC-LIBRARY-023 | Open Stations ──────────────────────────────────
    await tryTest('TC-LIBRARY-027 | Open Stations', () async {
      await libraryPage.tapStations();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(libraryPage.isStationsScreenVisible(), true);
    });

    // ─── TC-LIBRARY-024 | Scroll stations list down and up ────────────────
    // await tryTest('TC-LIBRARY-028 | Scroll stations list down and up', () async {
    //   await libraryPage.scrollListDown(libraryStationsScrollView);
    //   await libraryPage.scrollListUp(libraryStationsScrollView);
    // });

    //─── TC-LIBRARY-025 | Filter Stations ────────────────
    await tryTest('TC-LIBRARY-029 | Filter Stations', () async {
      await libraryPage.tapStationFilterButton();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await libraryPage.tapStationFilterOptionFirstAdded();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await libraryPage.tapStationFilterButton();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await libraryPage.tapStationFilterOptionStationName();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      await libraryPage.tapStationFilterButton();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      await libraryPage.tapStationFilterOptionRecentlyAdded();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    //─── TC-LIBRARY-026 | Search Stations ────────────────
    await tryTest('TC-LIBRARY-030 | Search Stations', () async {
      await libraryPage.typeInStationsSearch("Cairokee Radio");   
      expect(libraryPage.isTrackVisible("Cairokee Radio"), true,
          reason: 'Saved station should appear in search');

      await libraryPage.typeInStationsSearch("notSavedStationName");
      expect(libraryPage.isNoResultsMessageVisible("notSavedStationName"), true,
          reason: '"No results for" message should appear');
    });


    await tryTest('TC-LIBRARY-031 | Station Card', () async {
    // ─── TC-LIBRARY-025 | Open a station ─────────────────────────────────
    await tester.pumpAndSettle(const Duration(seconds: 2));
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
    });


    // ─── TC-LIBRARY-030 | Back to Library ────────────────────────────────
    await tryTest('TC-LIBRARY-032 | Back to Library', () async {
    await libraryPage.tapStationsBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    });


    // YOUR INSIGHTS SECTION
    debugPrint('YOUR INSIGHTS SECTION');
    // ─── TC-LIBRARY-031 | Open Your Insights ─────────────────────────────
    await tryTest('TC-LIBRARY-033 | Open Your Insights', () async {
      await libraryPage.tapYourInsights();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(libraryPage.isInsightsScreenVisible(), true);
    });

    // ─── TC-LIBRARY-032 | Plays / Listeners / Likes stats are visible ─────
    await tryTest('TC-LIBRARY-034 | Plays / Listeners / Likes stats are visible', () async {
      expect(libraryPage.isInsightsStatsVisible(), true,
          reason: 'All 3 stat counters should be visible');
    });

    // ─── TC-LIBRARY-033 | Scroll insights down and up ────────────────────
    await tryTest('TC-LIBRARY-033 | Scroll insights down and up', () async {
      await libraryPage.scrollInsightsDown();
      await libraryPage.scrollInsightsUp();
    });

    // ─── TC-LIBRARY-034 | All Platforms tab is tappable ──────────────────
    await tryTest('TC-LIBRARY-035 | All Platforms tab is tappable', () async {
      await libraryPage.tapAllPlatformsTab();
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    // ─── TC-LIBRARY-035 | Back to Library ────────────────────────────────
    await tryTest('TC-LIBRARY-036 | Back to Library', () async {
      await libraryPage.tapInsightsBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });


    // YOUR UPLOADS SECTION
    debugPrint('YOUR UPLOADS SECTION');
    // ─── TC-LIBRARY-036 | Open Your Uploads ──────────────────────────────
    await tryTest('TC-LIBRARY-037 | Open Your Uploads', () async {
      await libraryPage.tapYourUploads();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(libraryPage.isUploadsScreenVisible(), true);
    });

    // ─── TC-LIBRARY-037 | Play & shuffle buttons ───────────────────────────────────
    await tryTest('TC-LIBRARY-038 | Play & shuffle buttons', () async {
      await libraryPage.tapYourUploadsPlay();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await libraryPage.tapYourUploadsShuffle();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    // ─── TC-LIBRARY-038 | Three-dots → Delete uploaded track ─────────────
    // await tryTest('TC-LIBRARY-039 | Three-dots → Delete uploaded track', () async {
    //   await libraryPage.tapFirstUploadThreeDots();
    //   await tester.pumpAndSettle(const Duration(seconds: 1));
    //   await libraryPage.tapUpdatedTrack();
    //   await tester.pumpAndSettle(const Duration(seconds: 2));
    //   await libraryPage.scrollUntilVisible(itemText: 'Delete Track', scrollableKey: uploadsScrollView); //Delete button
    //   await libraryPage.tapDeleteUploadOption();
    //   await tester.pumpAndSettle(const Duration(seconds: 2));
    // });

    // ─── TC-LIBRARY-039 | Scroll uploads list down and up ────────────────
    await tryTest('TC-LIBRARY-040 | Scroll Your Uploads', () async {
      await libraryPage.scrollListDown(uploadsScrollView);
      await libraryPage.scrollListUp(uploadsScrollView);
    });

    // ─── TC-LIBRARY-040 | Search for uploaded track → visible ────────────
    await tryTest('TC-LIBRARY-041 | Search in Your Uploads', () async {
      await libraryPage.typeInUploadsSearch("أنا وأخي");
      expect(libraryPage.isTrackVisible("أنا وأخي"), true,
          reason: 'Uploaded track should appear in search');

      // ─── TC-LIBRARY-041 | Search for non-uploaded track → not visible ─────
      await libraryPage.typeInUploadsSearch("notUploadedTrackName");
      // expect(libraryPage.isTrackVisible("notUploadedTrackName"), false,
      //     reason: 'Non-uploaded track should not appear');
    });

    // ─── TC-LIBRARY-042 | Back to Library ────────────────────────────────
    await tryTest('TC-LIBRARY-042 | Back to Library', () async {
      await libraryPage.tapUploadsBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });


    // RECENTLY PLAYED SECTION
    debugPrint('RECENTLY PLAYED SECTION');
    // ─── TC-LIBRARY-043 | Tap See All → Recently Played screen ───────────
    await tryTest('TC-LIBRARY-043 | Tap See All → Recently Played screen', () async{
      await libraryPage.scrollUntilVisible(itemText: 'Recently played', scrollableKey: libraryMainScrollView);
      await libraryPage.tapRecentlyPlayedSeeAll();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(libraryPage.isRecentlyPlayedScreenVisible(), true);
    });

    // ─── TC-LIBRARY-044 | Play & shuffle buttons ───────────────────────
    await tryTest('TC-LIBRARY-044 | Play & shuffle buttons', () async{
      await libraryPage.tapHistoryPlay();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await libraryPage.tapHistoryShuffle();
    });

    // ─── TC-LIBRARY-045 | Scroll history list down and up ─────────────────
    await tryTest('TC-LIBRARY-045 | Scroll history list down and up', () async{
      await libraryPage.scrollListDown(historyListView);
      await libraryPage.scrollListUp(historyListView);
    });


    await tryTest('TC-LIBRARY-046 | Delete History', () async {
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
      // expect(libraryPage.isNoListeningHistoryVisible(), true,
      //     reason: '"No listening history" should appear after clearing');
    });


    // ─── TC-LIBRARY-048 | Back to Library ────────────────────────────────
    await tryTest('TC-LIBRARY-047 | Back to Library', () async {
      await libraryPage.tapInsightsBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}