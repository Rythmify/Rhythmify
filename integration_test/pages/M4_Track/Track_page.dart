import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class TrackPage extends BasePage {
  TrackPage(super.tester);

  Future<void> playFromHotForYou() async {
    await tapByKeyNow(hotForYouPlayButton);
    await tester.pump(const Duration(seconds: 3));
  }

  Future<void> openMiniPlayer() async {
    await tester.tap(find.byKey(const Key(playerMiniPlayerGesture)));
    await tester.pump(const Duration(seconds: 10));
  }

  Future<void> tapBehindThisTrack() async {
    await tester.tap(find.byKey(const Key(behindTheTrackBehindTrackButton)).last);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }


  Future<void> tapBack() async {
    await tapByKeyNow(behindTheTrackBackButton);
    await tester.pump(const Duration(seconds: 2));
  }

  bool isTrackInfoVisible() {
    return isVisible(behindTheTrackBackButton) &&
        find.byType(Image).evaluate().isNotEmpty;
  }

  bool isShowMoreVisible() => isVisible(behindTheTrackShowMore);

  bool isDescriptionSheetVisible() => find.text('Description').evaluate().isNotEmpty;

  bool isTagsVisible() => isVisible(behindTheTrackTagsListView);

  bool isFollowButtonVisible() =>
      find.text('Follow').evaluate().isNotEmpty ||
      find.text('Following').evaluate().isNotEmpty;

  bool isOnArtistPage() => isVisible(publicProfileBackButton);


  Future<void> tapPlayPause() async {
    await tapByKeyNow(behindTheTrackPlayPause);
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> tapShowMore() async {
    await tapByKeyNow(behindTheTrackShowMore);
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> closeDescriptionSheet() async {
    await tapByKeyNow(coreBottomSheetCloseButton);
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> scrollTagsHorizontally() async {
    await scrollHorizontallyInSection(behindTheTrackTagsListView);
  }

  Future<void> tapFollowButton() async {
    final finder = find.text('Follow').evaluate().isNotEmpty
        ? find.text('Follow')
        : find.text('Following');
    await tester.ensureVisible(finder.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(finder.first);
    await tester.pump(const Duration(seconds: 2));
  }

  Future<void> tapLike() async {
    final finder = find.byIcon(Icons.favorite_border).evaluate().isNotEmpty
        ? find.byIcon(Icons.favorite_border)
        : find.byIcon(Icons.favorite);
    await tester.tap(finder.first);
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> tapRepost() async {
    await tester.tap(find.byIcon(Icons.repeat).first);
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> tapComment() async {
    await tester.tap(find.byIcon(Icons.chat_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  Future<void> returnToBehindTheTrack() async {
    await tapByKeyNow(commentsBackButton);
    await tester.pump(const Duration(seconds: 2));
  }

  Future<void> tapMore() async {
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> dragToCloseMoreOptions() async {
    await tester.drag(
      find.byType(DraggableScrollableSheet).first,
      const Offset(0, 500),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> scrollUp() async {
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 1000),
    );
    await tester.pump(const Duration(seconds: 1));
  }

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
