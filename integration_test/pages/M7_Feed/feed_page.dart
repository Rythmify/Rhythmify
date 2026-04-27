import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class FeedPage extends BasePage {
  FeedPage(WidgetTester tester) : super(tester);

  Future<void> tapFeedButton() async => await tapByKey(feedNavButton);
  Future<void> tapDiscoverButton() async => await tapByKey(feedTabDiscover );
  Future<void> tapFollowingButton() async => await tapByKey(feedTabFollowing);
  Future<void> taplikeButton() async => await tapByKey(feedCardSideActionsLike);
  Future<void> tapCommentButton() async => await tapByKey(feedCardSideActionsComment);
  Future<void> closeComments() async => await tapByKey(commentsBackButton);
  Future<void> dragTrackCard() async => await tapByKey(feedCardBottomInfoPlayCircle);
  bool playerTrack() => isVisible (playerTrackInfoBoxDetails);
  bool isFeedPageVisible() => isVisible(feedCardCover);
  Future<void> tapDragtButton() async => await tapByKey(playerCollapseButton);
}
