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

  /// Taps the Playlists menu item in the Library screen.
  Future<void> goToPlaylistsSection() async {
    await tapByKey(libraryPlaylistsItem);
  }

  /// Taps the back button on the Playlists list screen.
  Future<void> goBackFromPlaylistsList() async {
    await tapByKey(libraryPlaylistsBackButton);
  }

  /// Taps the back button on the Playlist detail screen.
  Future<void> goBackFromPlaylistDetail() async {
    await tapByKey(playlistDetailBackButton);
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
  Future<void> tapOptionDelete() async {
    await tapByKey(optionsDelete);
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
  Future<void> removeTrack(String trackId) async {
    await tapByKey('edit_track_remove_$trackId');
  }

  // ── Suggestions (Playlist Detail) ──────────────────────────────────────────

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
}
