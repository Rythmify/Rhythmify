import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M2_Profile/profile_page.dart';
import '../../pages/M4_Track/Track_page.dart';
import '../../pages/M5_Player/Player_page.dart';
import '../../pages/M6_Playlist/Playlist_page.dart';
import '../../pages/M7_Feed/feed_page.dart';
import '../../pages/M7_Feed/home_page.dart';
import '../../pages/M8_Search/search_page.dart';
import '../../pages/M9_Comments/comments_page.dart';
import '../../pages/M10_Notifications/notification_page.dart';
import '../../pages/M13_Settings/settings_page.dart';
import '../../pages/User_one_main_flow/one_main_flow_page.dart';
import '../../pages/base_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('USER - ONE MAIN FLOW', (tester) async {
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
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final mainFlowPage    = OneMainFlowPage(tester);
    final loginPage       = LoginPage(tester);
    final profilePage     = ProfilePage(tester);
    final trackPage       = TrackPage(tester);
    final playerPage      = PlayerPage(tester);
    final playlistPage    = PlaylistPage(tester);
    final homePage        = HomePage(tester);
    final feedPage        = FeedPage(tester);
    final searchPage      = SearchPage(tester);
    final commentsPage    = CommentsPage(tester);
    final notificationsPage = NotificationsPage(tester);
    final settingsPage    = SettingsPage(tester);
    final basePage        = BasePage(tester);

    await tryTest('User log in to RYTHMIFY', () async {
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await loginPage.login(validEmail, validPassword);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(loginPage.isOnHomePage(), true);
    });

    await tryTest('User play a track "Hot for you', () async {
      await trackPage.playFromHotForYou();
      await playerPage.openFullPlayer();
      await tester.pump(const Duration (seconds: 3));
    });

    await tryTest('User like the track & write a comment', () async {
      await playerPage.tapLikeButton();
      await tester.pump(const Duration (seconds: 2));
      await commentsPage.sendCommentFromFloatingBar('testing comment');
      await commentsPage.openFromPlayer();
      await tester.pump(const Duration (seconds: 3));
      expect(commentsPage.isCommentVisible('testing comment'), true);
      await mainFlowPage.tapCloseCommentsSection();
      await playerPage.tapPlayPause();
      await tester.pump(const Duration (seconds: 2));
      await playerPage.tapCollapseButton();
      await tester.pump(const Duration (seconds: 2));
    });

    await tryTest('User wants to message a friend',() async {
      await homePage.tapMessageButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await mainFlowPage.tapFriendChat('Yomna');
      await tester.pump(const Duration(seconds: 3));
      await mainFlowPage.writeMessage('Hello!! I found out an amazing song, listen to it!!');
      await tester.pump(const Duration(seconds: 3));
      await mainFlowPage.sendMessage();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await mainFlowPage.tapAddIcon();
      await tester.pump(const Duration(seconds: 3));
      await mainFlowPage.tapLikeTrack();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await mainFlowPage.tapDoneButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await mainFlowPage.sendMessage();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    await tryTest('User wants to check likes on his tracks', () async {
      await homePage.tapNotificationButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await notificationsPage.tapFilterIcon();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await notificationsPage.tapFilterLikes();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await notificationsPage.waitForNotificationsToLoad();
      expect(notificationsPage.isFilterAppliedSuccessfully(), true,
          reason: 'Filter should be applied — list or empty message visible');
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    await tryTest('User see what is new from feed page', () async {
      await feedPage.tapFeedButton();
      await tester.pump(const Duration(seconds: 3));
      await mainFlowPage.swipeToNextTrack();
      // await tester.pump(const Duration(milliseconds: 500));
      await mainFlowPage.swipeToNextTrack();
      await tester.pump(const Duration(milliseconds: 500));
      await mainFlowPage.swipeToPreviousTrack();
      await tester.pump(const Duration(milliseconds: 500));
    });

    await tryTest('User want to search a playlist & listen to it', () async {
      await searchPage.tapSearchNavButton();
      await searchPage.typeQuery('my playlist');
      await searchPage.submitSearch();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(searchPage.isResultsScreenVisible(), true,
          reason: 'Searching "my playlist" should navigate to the results screen');
      await searchPage.tapPlaylistsResultsTab();
      await mainFlowPage.tapPlaylist(0);
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await mainFlowPage.playPlaylist();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await mainFlowPage.backToSearchResults();
      await searchPage.clearSearch();
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    await tryTest('User want to create a new playlist', () async {
      await playlistPage.goToLibraryTab();
      await playlistPage.goToPlaylistsSection();
      await playlistPage.tapCreateButton();
      await playlistPage.fillPlaylistName('New Playlist');    
      await playlistPage.tapConfirmCreate();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await playlistPage.tapAddTrackButton();
      await playlistPage.tapSuggestionAddButtonByIndex(0);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await playlistPage.tapSuggestionAddButtonByIndex(1);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await playlistPage.goBackFromPlaylistDetail();
      expect(playlistPage.isOnPlaylistsListScreen(), true,
          reason: 'Should be back on the Playlists list');
      await mainFlowPage.backToLibraryPlaylistButton();
    });

    await tryTest('User want edits his profile name', () async {
      await profilePage.tapProfileAvatar();
      await profilePage.tapEdit();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(profilePage.isOnEditProfilePage(), true);
      await profilePage.enterName(profileEditNewName);
      await profilePage.tapSave();
      await tester.pumpAndSettle(const Duration(seconds: 4));
      await basePage.scrollUntilVisible(itemText: 'User test', scrollableKey: publicProfilePage);
      await mainFlowPage.goBackFromProfile();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    await tryTest('User finish all what he want and will sign out', () async {
      await profilePage.goToLibraryTab();
      await settingsPage.tapSettingsIcon();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await settingsPage.tapSignOut();
      await settingsPage.tapOK();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect (settingsPage.isOnBoardingPage(), true);
    });
    
    debugPrint('FEEDBACK: user: fantastic user experinece I will use it all the time!!!');

    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}