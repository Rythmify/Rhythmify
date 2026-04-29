import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class TrackPage extends BasePage {
  TrackPage(super.tester);

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Taps the play button on the first Hot For You track card.
  Future<void> playFromHotForYou() async {
    await tapByKeyNow(hotForYouPlayButton);
    await tester.pump(const Duration(seconds: 3));
  }

  /// Taps the mini player bar to open the full player screen.
  Future<void> openMiniPlayer() async {
    await tester.tap(find.byKey(const Key(playerMiniPlayerGesture)));
    await tester.pump(const Duration(seconds: 10));
  }

  /// Taps the "Behind this track" button in the full player to open the
  /// Behind the Track page.
  Future<void> tapBehindThisTrack() async {
  await tester.tap(find.byKey(const Key(behindTheTrackBehindTrackButton)).last);
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

  /// Taps the AppBar back button to leave the Behind the Track page.
  Future<void> tapBack() async {
    await tapByKeyNow(behindTheTrackBackButton);
    await tester.pump(const Duration(seconds: 2));
  }

  // ── Behind the Track — State Checks ───────────────────────────────────────

  /// True when the Behind the Track page is loaded (back button and cover art
  /// image are both rendered, confirming the data fetch succeeded).
  bool isTrackInfoVisible() {
    return isVisible(behindTheTrackBackButton) &&
        find.byType(Image).evaluate().isNotEmpty;
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
  bool isFollowButtonVisible() =>
      find.text('Follow').evaluate().isNotEmpty ||
      find.text('Following').evaluate().isNotEmpty;

  /// True when the artist public-profile page is showing.
  bool isOnArtistPage() => isVisible(publicProfileBackButton);


  // ── Behind the Track — Actions ─────────────────────────────────────────────

  /// Taps the play/pause button in the action bar.
  Future<void> tapPlayPause() async {
    await tapByKeyNow(behindTheTrackPlayPause);
    await tester.pump(const Duration(seconds: 1));
  }

  /// Taps "Show more" to open the description bottom sheet.
  Future<void> tapShowMore() async {
    await tapByKeyNow(behindTheTrackShowMore);
    await tester.pump(const Duration(seconds: 1));
  }

  /// Closes the description bottom sheet by tapping the close button.
  Future<void> closeDescriptionSheet() async {
    await tapByKeyNow(coreBottomSheetCloseButton);
    await tester.pump(const Duration(seconds: 1));
  }

  /// Drags the tags row horizontally to verify it is scrollable.
  Future<void> scrollTagsHorizontally() async {
    await scrollHorizontallyInSection(behindTheTrackTagsListView);
  }

  /// Taps the Follow / Following button (found by text; key is user-id-scoped in source).
  Future<void> tapFollowButton() async {
    final finder = find.text('Follow').evaluate().isNotEmpty
        ? find.text('Follow')
        : find.text('Following');
    await tester.ensureVisible(finder.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(finder.first);
    await tester.pump(const Duration(seconds: 2));
  }

  /// Taps the like button in the action bar.
  Future<void> tapLike() async {
    final finder = find.byIcon(Icons.favorite_border).evaluate().isNotEmpty
        ? find.byIcon(Icons.favorite_border)
        : find.byIcon(Icons.favorite);
    await tester.tap(finder.first);
    await tester.pump(const Duration(seconds: 1));
  }

  /// Taps the repost button in the action bar.
  Future<void> tapRepost() async {
    await tester.tap(find.byIcon(Icons.repeat).first);
    await tester.pump(const Duration(seconds: 1));
  }

  /// Taps the comment button in the action bar and waits for the comments page.
  Future<void> tapComment() async {
    await tester.tap(find.byIcon(Icons.chat_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// Closes the comments page and returns to Behind the Track.
  Future<void> returnToBehindTheTrack() async {
    await tapByKeyNow(commentsBackButton);
    await tester.pump(const Duration(seconds: 2));
  }

  /// Taps the 3-dot more-options button in the action bar.
  Future<void> tapMore() async {
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Drags the more-options bottom sheet downward to dismiss it.
  Future<void> dragToCloseMoreOptions() async {
    await tester.drag(
      find.byType(DraggableScrollableSheet).first,
      const Offset(0, 500),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Scrolls the Behind the Track page back to the top.
  Future<void> scrollUp() async {
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 1000),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  /// Taps the artist row to navigate to the artist's public profile.
  Future<void> tapArtist() async {
    final artistFinder = find.byWidgetPredicate(
      (widget) =>
          widget.key?.toString().contains('track_details_section_artist_inkwell_') == true,
    );
    await tester.ensureVisible(artistFinder.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(artistFinder.first);
    await tester.pump(const Duration(seconds: 2));
  }

  bool isFansLeaderboardVisible() =>
      find.byWidgetPredicate(
        (widget) => widget.key?.toString().contains('behind_the_track_fans_leaderboard_') == true,
      ).evaluate().isNotEmpty;

  Future<void> scrollToFansLeaderboard() async {
    final finder = find.byWidgetPredicate(
      (widget) => widget.key?.toString().contains('behind_the_track_fans_leaderboard_') == true,
    );
    for (int i = 0; i < 10; i++) {
      if (finder.evaluate().isNotEmpty) break;
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -300),
      );
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  Future<void>backToHome() async {
    await tapByKeyNow(behindTheTrackBackButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  Future<void> tapTopSegment() async {
    await tapByKey(fansLeaderboardOverallButton);
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> tapFirstSegment() async {
    await tapByKey(fansLeaderboardSevenDaysButton);
    await tester.pump(const Duration(seconds: 1));
  }
}
