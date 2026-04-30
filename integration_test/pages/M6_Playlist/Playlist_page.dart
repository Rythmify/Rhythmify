import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class PlaylistPage extends BasePage {
  PlaylistPage(super.tester);

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Taps the Library tab in the bottom navigation bar.
  Future<void> goToLibraryTab() async {
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Taps the Library tab to return to the main Library screen.
  Future<void> goBackToLibrary() async {
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Taps the Playlists menu item in the Library screen.
  Future<void> goToPlaylistsSection() async {
    await tapByKey(libraryPlaylistsItem);
  }

  /// Taps the Albums menu item in the Library screen.
  Future<void> goToAlbumsSection() async {
    await tapByKey(libraryAlbumsItem);
  }

  /// Taps the back button on the Playlists list screen.
  Future<void> goBackFromPlaylistsList() async {
    await tapByKey(libraryPlaylistsBackButton);
  }

  /// Taps the back button on the Playlist detail screen.
  Future<void> goBackFromPlaylistDetail() async {
    await tapByKey(playlistDetailBackButton);
  }

  /// Taps the playlist with [name] in the playlists list to open its detail screen.
  Future<void> tapPlaylistInList(String playlistName) async {
    await tester.tap(find.text(playlistName));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Taps the ⋮ more button next to the playlist with [name] in the playlists list.
  Future<void> tapMoreForPlaylist(String playlistName) async {
    final tileRow = find.ancestor(
      of: find.text(playlistName),
      matching: find.byType(Row),
    ).first;
    await tester.tap(
      find.descendant(of: tileRow, matching: find.byIcon(Icons.more_vert)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  // ── Playlist Filter ────────────────────────────────────────────────────────

  /// Taps the filter button on the Playlists list screen.
  Future<void> tapPlaylistFilterButton() async {
    await tapByKey(libraryPlaylistsFilterButton);
  }

  Future<void> tapPlaylistFilterOptionFirstAdded() async {
    await tapByKey(libraryPlaylistsFilterFirstAdded);
  }

  Future<void> tapPlaylistFilterOptionRecentlyUpdated() async {
    await tapByKey(libraryPlaylistsFilterRecentlyUpdated);
  }

  Future<void> tapPlaylistFilterOptionPlaylistName() async {
    await tapByKey(libraryPlaylistsFilterPlaylistName);
  }

  Future<void> tapPlaylistFilterOptionLikedPlayists() async {
    await tapByKey(libraryPlaylistsFilterLikedPlaylists);
  }

  Future<void> tapPlaylistFilterOptionOwnedPlayists() async {
    await tapByKey(libraryPlaylistsFilterOwnedPlaylists);
  }

  Future<void> tapPlaylistFilterOptionAllPlayists() async {
    await tapByKey(libraryPlaylistsFilterAllPlaylists);
  }

  // ── Create Playlist ─────────────────────────────────────────────────────────

  /// Taps the "+" create button on the Playlists list screen.
  Future<void> tapCreateButton() async {
    await tapByKey(libraryPlaylistsCreateButton);
  }

  /// Types [name] into the playlist name field in the Create sheet.
  Future<void> fillPlaylistName(String name) async {
    await enterTextByKey(createPlaylistNameField, name);
  }

  /// Taps the Create button in the Create Playlist bottom sheet.
  Future<void> tapConfirmCreate() async {
    await tapByKey(createPlaylistCreateButton);
  }

  /// Taps the Cancel button in the Create Playlist bottom sheet.
  Future<void> tapCancelCreate() async {
    await tapByKey(createPlaylistCancelButton);
  }

  // ── Playlist Detail — Options sheet ────────────────────────────────────────

  /// Taps the ⋮ more button on the Playlist detail screen.
  Future<void> tapMoreOptions() async {
    await tapByKey(playlistDetailMoreButton);
  }

  /// Taps the "Edit playlist" option in the options sheet.
  Future<void> tapOptionEdit() async {
    await tapByKey(optionsEdit);
  }

  /// Taps the "Make public / Make private" toggle option.
  Future<void> tapOptionTogglePrivacy() async {
    await tapByKey(optionsTogglePrivacy);
  }

  /// Taps the "Delete playlist" option in the options sheet.
  /// Drags the sheet upward first so the Delete option becomes visible.
  Future<void> tapOptionDelete() async {
    await tester.dragUntilVisible(
      find.byKey(Key(optionsDelete)),
      find.byKey(Key(optionsLike)),
      const Offset(0, -100),
      maxIteration: 20,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(optionsDelete)));
    await tester.pumpAndSettle();
  }

  /// Taps Cancel in the delete confirmation dialog.
  Future<void> cancelDelete() async {
    await tapByKey(deletePlaylistCancelButton);
  }

  /// Taps Confirm/Delete in the delete confirmation dialog.
  Future<void> confirmDelete() async {
    await tapByKey(deletePlaylistConfirmButton);
  }

  // ── Edit Playlist Sheet ─────────────────────────────────────────────────────

  /// Replaces the playlist name field content with [name] in the Edit sheet.
  Future<void> fillEditName(String name) async {
    await enterTextByKey(editPlaylistNameField, name);
  }

  /// Replaces the description field content with [description] in the Edit sheet.
  Future<void> fillEditDescription(String description) async {
    await enterTextByKey(editPlaylistDescriptionField, description);
  }

  /// Taps the Public switch in the Edit sheet.
  Future<void> tapEditPublicSwitch() async {
    await tapByKey(editPlaylistPublicSwitch);
  }

  /// Taps the Save button in the Edit sheet.
  Future<void> tapSaveEdit() async {
    await tapByKey(editPlaylistSaveButton);
  }

  /// Taps the Cancel button in the Edit sheet.
  Future<void> tapCancelEdit() async {
    await tapByKey(editPlaylistCancelButton);
  }

  /// Taps the remove (red minus) button for [trackId] in the Edit sheet.
  Future<void> removeTrack(int index) async {
    await tapByKey('edit_track_remove_$index');
     await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  // ── Suggestions (Playlist Detail) ──────────────────────────────────────────

  /// Taps the "Add track" button on the Playlist detail screen to open suggestions.
  Future<void> tapAddTrackButton() async {
    await tapByKey(playlistDetailAddTrackButton);
  }

  /// Taps the add button for the suggestion at [index] in the suggestions list.
  /// Uses icon-based lookup because suggestion keys include the track ID, not the index.
  Future<void> tapSuggestionAddButtonByIndex(int index) async {
    final buttons = find.byIcon(Icons.add_box_outlined);
    await tester.ensureVisible(buttons.at(index));
    await tester.pumpAndSettle();
    await tester.tap(buttons.at(index));
    await tester.pumpAndSettle();
  }

  /// Scrolls to and taps the add button for the suggestion with [suggestionId].
  Future<void> addSuggestion(String suggestionId) async {
    final button = find.byKey(Key('add_suggestion_$suggestionId'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Taps the Refresh button to reload the suggestion list.
  Future<void> tapRefreshSuggestions() async {
    await tapByKey(refreshSuggestionsButton);
  }

  // ── Playlist Detail — Action buttons ───────────────────────────────────────

  /// Taps the Like button on the Playlist detail screen.
  Future<void> tapLikeButton() async {
    await tapByKey(playlistDetailLikeButton);
  }

  // ── Convert to Album ───────────────────────────────────────────────────────

  /// Taps the "Convert to Album" option in the Edit sheet.
  Future<void> tapConvertToAlbum() async {
    await tapByKey(editConvertToAlbum);
  }

  /// Taps Cancel in the convert-to-album confirmation dialog.
  Future<void> cancelConvertToAlbum() async {
    await tapByKey(convertToAlbumCancelButton);
  }

  /// Taps Confirm in the convert-to-album confirmation dialog.
  Future<void> confirmConvertToAlbum() async {
    await tapByKey(convertToAlbumConfirmButton);
  }

  /// Pulls down to trigger a refresh on the current screen.
  Future<void> refreshPage() async {
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 300));
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  // ── State Checks ───────────────────────────────────────────────────────────

  /// True when the Playlists list screen is active (back button present).
  bool isOnPlaylistsListScreen() => isVisible(libraryPlaylistsBackButton);

  /// True when the Playlist detail screen is active (back button present).
  bool isOnPlaylistDetailScreen() => isVisible(playlistDetailBackButton);

  /// True when a widget with exactly [name] exists in the tree.
  bool isPlaylistNameVisible(String name) =>
      find.text(name).evaluate().isNotEmpty;

  /// True when a track title [title] is visible in the detail or edit sheet.
  bool isTrackVisible(String title) =>
      find.text(title).evaluate().isNotEmpty;

  /// True when the Edit playlist sheet is open (Save button present).
  bool isEditSheetOpen() => isVisible(editPlaylistSaveButton);

  /// True when a widget with exactly [name] exists — used for album name checks.
  bool isAlbumNameVisible(String name) =>
      find.text(name).evaluate().isNotEmpty;

  /// Search for playlists with [query] and returns true if the "No results for [query]" message is shown.
    Future<void> typeInPlaylistSearch(String query) async {
    await enterTextByKey(libraryPlaylistsSearchField, query);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
}
