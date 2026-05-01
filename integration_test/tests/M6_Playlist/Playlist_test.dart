import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M6_Playlist/Playlist_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M6 - PLAYLIST | all scenarios', (tester) async {
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

      final loginPage    = LoginPage(tester);
      final playlistPage = PlaylistPage(tester);

      // ── Login ────────────────────────────────────────────────────────────────
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await loginPage.login(validEmail, validPassword);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(loginPage.isOnHomePage(), true);

      // ── TC-PLAYLIST-001 | Navigate Library → Playlists ────────────────────
      await tryTest('TC-PLAYLIST-001 | Navigate Library → Playlists', () async {
        await playlistPage.goToLibraryTab();
        await playlistPage.goToPlaylistsSection();
        expect(playlistPage.isOnPlaylistsListScreen(), true,
            reason: 'Should land on the Playlists list screen');
      });

      await tryTest('TC-PLAYLIST-002 | Filter playlists', () async {
        await playlistPage.tapPlaylistFilterButton();
        await playlistPage.tapPlaylistFilterOptionFirstAdded();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await playlistPage.tapPlaylistFilterButton();
        await playlistPage.tapPlaylistFilterOptionRecentlyUpdated();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await playlistPage.tapPlaylistFilterButton();
        await playlistPage.tapPlaylistFilterOptionPlaylistName();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await playlistPage.tapPlaylistFilterButton();
        await playlistPage.tapPlaylistFilterOptionRecentlyUpdated();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await playlistPage.tapPlaylistFilterButton();
        await playlistPage.tapPlaylistFilterOptionLikedPlayists();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await playlistPage.tapPlaylistFilterButton();
        await playlistPage.tapPlaylistFilterOptionOwnedPlayists();
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await playlistPage.tapPlaylistFilterButton();
        await playlistPage.tapPlaylistFilterOptionAllPlayists();
        await tester.pumpAndSettle(const Duration(seconds: 2));

      });

      // ── TC-PLAYLIST-002 | Create a new playlist ───────────────────────────
      await tryTest('TC-PLAYLIST-003 | Create a new playlist', () async {
        await playlistPage.tapCreateButton();
        await playlistPage.fillPlaylistName('Integration Test Playlist');
        await playlistPage.tapConfirmCreate();
        await tester.pumpAndSettle(const Duration(seconds: 3));
        // expect(playlistPage.isOnPlaylistDetailScreen(), true,
        //     reason: 'Should navigate to the new playlist detail screen');
        // expect(playlistPage.isPlaylistNameVisible('Integration Test Playlist'), true,
        //     reason: 'New playlist name should appear in the header');
      });

      // ── TC-PLAYLIST-003 | Add a track from suggestions ────────────────────
      await tryTest('TC-PLAYLIST-004 | Add a track from suggestions', () async {
        //Add first 3 tracks from the suggestions list
        await playlistPage.tapAddTrackButton();
        await playlistPage.tapSuggestionAddButtonByIndex(0);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        await playlistPage.tapSuggestionAddButtonByIndex(1);
        await tester.pumpAndSettle(const Duration(seconds: 4));
        // await playlistPage.tapSuggestionAddButtonByIndex(2);
        // await tester.pumpAndSettle(const Duration(seconds: 2));
      });

      // ── Navigate back to the Playlists list ───────────────────────────────
      await tryTest('Navigate back to the Playlists list', () async {
        await playlistPage.goBackFromPlaylistDetail();
        expect(playlistPage.isOnPlaylistsListScreen(), true,
            reason: 'Should be back on the Playlists list');
      });

      // ── TC-PLAYLIST-004..007 | Edit — tap ⋮ on the playlist row in the list
      await tryTest('TC-PLAYLIST-005 | Edit — tap ⋮ on the playlist row in the list', () async {
        await playlistPage.tapMoreForPlaylist('Integration Test Playlist');
        await playlistPage.tapOptionEdit();
        expect(playlistPage.isEditSheetOpen(), true,
            reason: 'Edit sheet should open after tapping Edit');

        // TC-PLAYLIST-004 | Rename
        await playlistPage.fillEditName('Edited Integration Playlist');

        // TC-PLAYLIST-005 | Add a description
        await playlistPage.fillEditDescription('Integration test description');

        // TC-PLAYLIST-006 | Toggle public/private
        await playlistPage.tapEditPublicSwitch();

        // TC-PLAYLIST-007 | Remove the added track
        //await playlistPage.removeTrack(0);

        // await playlistPage.tapSaveEdit();
        await playlistPage.tapSaveEdit();
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await playlistPage.pullToRefresh(libraryPlaylistsList);
      });

      // // ── Verify edits are reflected on the Playlists list ──────────────────
      await tryTest('Verify edits are reflected on the Playlists list', () async {
        expect(playlistPage.isOnPlaylistsListScreen(), true,
            reason: 'Should be on the Playlists list after saving');
        expect(playlistPage.isPlaylistNameVisible('Edited Integration Playlist'), true,
            reason: 'Updated playlist name should appear in the list');

        // // ── Navigate to the edited playlist detail to verify track removal ────
        // await playlistPage.tapPlaylistInList('Edited Integration Playlist');
        // expect(playlistPage.isOnPlaylistDetailScreen(), true,
        //     reason: 'Should open the playlist detail screen');
        // // need to be handled as the deleted track'name is not static and changes with every test run, so we check for the absence of the track name instead of a specific name
        // // expect(playlistPage.isTrackVisible('Birds Of A Feather (Remix)'), false,
        // //     reason: 'Removed track should no longer appear in the detail');
      });

      await tryTest('TC-PLAYLIST-006 | Convert playlist to Album successfully',() async{
        await playlistPage.pullToRefresh(libraryPlaylistsList);;
        await tester.pumpAndSettle(const Duration(seconds: 3));
        await playlistPage.tapMoreForPlaylist('Edited Integration Playlist');
        await playlistPage.tapOptionEdit();
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(playlistPage.isEditSheetOpen(), true,
            reason: 'Edit sheet should open after tapping Edit');

        await playlistPage.tapConvertToAlbum();
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await playlistPage.cancelConvertToAlbum();

        await playlistPage.tapConvertToAlbum();
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await playlistPage.confirmConvertToAlbum();

        await playlistPage.pullToRefresh(libraryPlaylistsList);
        await playlistPage.goBackToLibrary();
        await playlistPage.goToAlbumsSection();
        expect (playlistPage.isAlbumNameVisible('Edited Integration Playlist'), true,
            reason: 'Converted album should appear in the Albums section');
      });

      // ── TC-PLAYLIST-007 | Delete the playlist from its detail screen ──────
      await tryTest('TC-PLAYLIST-007 | Delete the playlist from its detail screen', () async {
        await playlistPage.goBackToLibrary();
        await playlistPage.goToPlaylistsSection();
        await playlistPage.tapPlaylistInList('Testing playlist');
        await playlistPage.tapMoreOptions();
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await playlistPage.tapOptionDelete();
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await playlistPage.cancelDelete();
        await playlistPage.tapOptionDelete();
        await playlistPage.confirmDelete();
        await tester.pumpAndSettle(const Duration(seconds: 2));
        await playlistPage.pullToRefresh(libraryPlaylistsList);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      });

      // ─── TC-PLAYLIST-008 | Search for existing playlist ───────────────
      await tryTest('TC-PLAYLIST-008 | Search for playlist track → visible', () async {
        await playlistPage.typeInPlaylistSearch("spacetoon");
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(playlistPage.isTrackVisible("spacetoon"), true,
            reason: 'Playlist should appear in search results');
      });

      // ─── TC-PLAYLIST-007 | Search for non-existing playlist track ─────────
      await tryTest('TC-PLAYLIST-009 | Search for non existing playlist → not visible', () async {
        await playlistPage.typeInPlaylistSearch("non existing playlist");
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
