import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import 'package:flutter/material.dart';
import '../../selectors/selectors.dart';

class OneMainFlowPage extends BasePage {
  OneMainFlowPage(super.tester);
  Future<void> _tapByText(String text) async {
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }
  // -- Comment Scenario --
  Future<void> tapCloseCommentsSection() async => tapByKey(commentsBackButton);

  // -- Messaging Scenario --
  Future<void> tapFriendChat(String name) async {
    await tester.tap(find.byKey(Key(messagingInboxItemTile(name))));
    await tester.pumpAndSettle();
  }

  Future<void> writeMessage(String query) async {
    await enterTextByKey(messagingMessageInputField, query);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> sendMessage() async => await tapByKey(chatScreenSendButton);

  Future<void> tapAddIcon() async => await tapByKey(chatScreenAddEmbedButton);

  Future<void> tapLikeTrack() async => await _tapByText('أنا وأخي');

  Future<void> tapDoneButton() async => await tapByKey(doneButton);

  // -- Feed Scenario
  Future<void> swipeToNextTrack() async {
    await tester.drag(
      find.byKey(const Key(feedListDiscoverPageview)),
      const Offset(0, -600), // swipe up → next track
    );
    await tester.pumpAndSettle();
  }

  Future<void> swipeToPreviousTrack() async {
    await tester.drag(
      find.byKey(const Key(feedListDiscoverPageview)),
      const Offset(0, 600), // swipe down → previous track
    );
    await tester.pumpAndSettle();
  }

  Future<void> backToSearchResults() async => await tapByKey(playlistDetailBackButton);

  Future<void> tapTrack(int index) async{
    await tester.tap(find.byKey(Key(trackTile(index))));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> tapTrackMoreOptions(int index) async {
    final moreButtons = find.byWidgetPredicate(
      (widget) => widget.key is ValueKey<String> &&
                  (widget.key as ValueKey<String>).value.startsWith('track_card_') &&
                  (widget.key as ValueKey<String>).value.endsWith('_more_inkwell'),
    );
    await tester.tap(moreButtons.at(index));
    await tester.pumpAndSettle();
  }
  Future <void> tapAddToPlaylist() async => await tapByKey(trackOptionAddToPlaylist);
  Future <void> tapNewPlaylist() async => await _tapByText('New playlist');
  Future <void> writePlaylistName( String playlistName) async {
      await enterTextByKey(trackOptionAddToPlaylist, playlistName);
      await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  Future <void> tapCreate() async => await _tapByText('Craete');
  Future <void> tapDone() async => await _tapByText('Done');

  Future<void> playPlaylist() async => await tapByKey(playlistDetailPlayButton);

  Future<void> tapPlaylist(int index) async{
    await tester.tap(find.byKey(Key(playlisTile(index))));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  Future<void> backToLibraryPlaylistButton() async => await tapByKey(libraryPlaylistsBackButton);

  // -- Profile scenario --
  Future<void> goBackFromProfile() async => await tapByKey(publicProfileBackButton);

  // -- Debug the Failure --
  Future<void> pauseTheTrack() async => await tapByKey(playerMiniPlayerPlayPauseButton);
}