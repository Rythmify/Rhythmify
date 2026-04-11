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

  testWidgets(
    'TC-PLAYLIST-001..008 | Playlist — full feature flow',
    (tester) async {
      app.main();
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
      await playlistPage.goToLibraryTab();
      await playlistPage.goToPlaylistsSection();
      expect(playlistPage.isOnPlaylistsListScreen(), true,
          reason: 'Should land on the Playlists list screen');

      // ── TC-PLAYLIST-002 | Create a new playlist ───────────────────────────
      await playlistPage.tapCreateButton();
      await playlistPage.fillPlaylistName('Integration Test Playlist');
      await playlistPage.tapConfirmCreate();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(playlistPage.isOnPlaylistDetailScreen(), true,
          reason: 'Should navigate to the new playlist detail screen');
      expect(playlistPage.isPlaylistNameVisible('Integration Test Playlist'), true,
          reason: 'New playlist name should appear in the header');

      // ── TC-PLAYLIST-003 | Add a track from suggestions ────────────────────
      await playlistPage.addSuggestion('sg-001');

      expect(playlistPage.isTrackVisible('Birds Of A Feather (Remix)'), true,
          reason: 'Added suggestion should appear in the track list');

      // ── Navigate back to the Playlists list ───────────────────────────────
      await playlistPage.goBackFromPlaylistDetail();
      expect(playlistPage.isOnPlaylistsListScreen(), true,
          reason: 'Should be back on the Playlists list');

      // ── TC-PLAYLIST-004..007 | Edit — tap ⋮ on the playlist row in the list
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
      await playlistPage.removeTrack('sg-001');

      await playlistPage.tapSaveEdit();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // ── Verify edits are reflected on the Playlists list ──────────────────
      expect(playlistPage.isOnPlaylistsListScreen(), true,
          reason: 'Should be on the Playlists list after saving');
      expect(playlistPage.isPlaylistNameVisible('Edited Integration Playlist'), true,
          reason: 'Updated playlist name should appear in the list');

      // ── Navigate to the edited playlist detail to verify track removal ────
      await playlistPage.tapPlaylistInList('Edited Integration Playlist');
      expect(playlistPage.isOnPlaylistDetailScreen(), true,
          reason: 'Should open the playlist detail screen');
      expect(playlistPage.isTrackVisible('Birds Of A Feather (Remix)'), false,
          reason: 'Removed track should no longer appear in the detail');

      // ── TC-PLAYLIST-008 | Delete the playlist from its detail screen ──────
      // await playlistPage.tapMoreOptions();
      // await playlistPage.tapOptionDelete();
      // await tester.pumpAndSettle(const Duration(seconds: 2));

      // expect(playlistPage.isOnPlaylistsListScreen(), true,
      //     reason: 'Should navigate back to Playlists list after deletion');
      // expect(
      //   playlistPage.isPlaylistNameVisible('Edited Integration Playlist'),
      //   false,
      //   reason: 'Deleted playlist should no longer appear in the list',
      // );
    },
  );
}
