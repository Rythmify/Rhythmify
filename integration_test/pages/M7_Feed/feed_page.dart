import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class FeedPage extends BasePage {
  FeedPage(WidgetTester tester) : super(tester);

  Future<void> tapFeedButton() async => await tapByKey(feedNavButton);
  Future<void> tapDiscoverButton() async => await tapByKey(feedTabDiscover );
  // Future<void> tap
  Future<void> tapFollowingButton() async => await tapByKey(feedTabFollowing);
  Future<void> taplikeButton() async => await tapByKey(feedCardSideActionsLike);
  Future<void> tapCommentButton() async => await tapByKey(feedCardSideActionsComment);
  Future<void> DragTrackCard() async => await tapByKey(feedCardBottomInfoPlayCircle);
  bool PlayerTrack() => isVisible (playerTrackInfoBoxDetails);
  Future<void> tapDragtButton() async => await tapByKey(playerProgressBarSlider);
  Future<void> scrollDown() async {
    const Offset(0, -100);
    maxIteration: 50;
    await tester.pump(const Duration(milliseconds: 500));
  }
  Future<void> scrollUp() async {
    const Offset(0, 100);
    maxIteration: 50;
    await tester.pump(const Duration(milliseconds: 500));
  }

}
