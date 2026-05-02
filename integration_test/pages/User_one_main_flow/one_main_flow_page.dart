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

  // -- Search Scenario
  Future<void> backToSearchResults() async => await tapByKey(playlistDetailBackButton);

  // -- Playlist Scenrio --
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