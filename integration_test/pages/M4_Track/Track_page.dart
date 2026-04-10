import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class TrackPage extends BasePage {
  TrackPage(super.tester);

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Taps the play button on the first Hot For You track card.
  Future<void> playFromHotForYou() async {
    await tapByKey(hotForYouPlayButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Taps the mini player bar to open the full player screen.
  Future<void> openMiniPlayer() async {
    await tapByKey(playerMiniPlayerGesture);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Taps the "Behind this track" button in the full player to open the
  /// Behind the Track page.
  Future<void> tapBehindThisTrack() async {
    await tapByKey(behindTheTrackBehindTrackButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Taps the AppBar back button to leave the Behind the Track page.
  Future<void> tapBack() async {
    await tapByKey(behindTheTrackBackButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // ── Behind the Track — State Checks ───────────────────────────────────────

  /// True when the Behind the Track page is loaded (back button and cover art
  /// image are both rendered, confirming the data fetch succeeded).
  bool isTrackInfoVisible() {
    return isVisible(behindTheTrackBackButton) &&
        find.byType(Image).evaluate().isNotEmpty;
  }

  /// True when all action-bar elements are visible:
  /// like, repost, comment icons + the 3-dot more icon + play/pause button.
  bool isActionBarVisible() {
    return isVisible(behindTheTrackPlayPause) &&
        find.byIcon(Icons.favorite_border).evaluate().isNotEmpty &&
        find.byIcon(Icons.repeat).evaluate().isNotEmpty &&
        find.byIcon(Icons.chat_outlined).evaluate().isNotEmpty &&
        find.byIcon(Icons.more_vert).evaluate().isNotEmpty;
  }

  /// True when the "Show more" description link is rendered
  /// (only present when the track has a non-empty description).
  bool isShowMoreVisible() => isVisible(behindTheTrackShowMore);

  /// True when the description bottom sheet is open (title "Description" shown).
  bool isDescriptionSheetVisible() =>
      find.text('Description').evaluate().isNotEmpty;

  /// True when the tags horizontal list is rendered
  /// (only present when the track has at least one tag).
  bool isTagsVisible() => isVisible(behindTheTrackTagsListView);

  /// True when the follow/following button is rendered.
  bool isFollowButtonVisible() => isVisible(behindTheTrackFollowButton);

  /// True when "Fans Leaderboard" heading is in the widget tree.
  bool isFansLeaderboardVisible() =>
      find.text('Fans Leaderboard').evaluate().isNotEmpty;

  // ── Behind the Track — Actions ─────────────────────────────────────────────

  /// Taps the play/pause button in the action bar.
  Future<void> tapPlayPause() async {
    await tapByKey(behindTheTrackPlayPause);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Taps "Show more" to open the description bottom sheet.
  Future<void> tapShowMore() async {
    await tapByKey(behindTheTrackShowMore);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Closes the description bottom sheet by tapping the close button.
  Future<void> closeDescriptionSheet() async {
    await tapByKey(coreBottomSheetCloseButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Drags the tags row horizontally to verify it is scrollable.
  Future<void> scrollTagsHorizontally() async {
    await scrollHorizontallyInSection(behindTheTrackTagsListView);
  }

  /// Taps the Follow / Following button.
  Future<void> tapFollowButton() async {
    await tapByKey(behindTheTrackFollowButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Scrolls the page down until the Fans Leaderboard section is visible,
  /// using the same scrollUntilVisible pattern as the registration dropdowns.
  Future<void> scrollToFansLeaderboard() async {
    await scrollUntilVisible(
      itemText: 'Fans Leaderboard',
      scrollableKey: behindTheTrackScrollView,
    );
  }

  /// Taps the "Top" segment button in the Fans Leaderboard.
  Future<void> tapTopSegment() async {
    await tapByKey(fansLeaderboardTopButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// Taps the "First" segment button in the Fans Leaderboard.
  Future<void> tapFirstSegment() async {
    await tapByKey(fansLeaderboardFirstButton);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }
}
