import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class NotificationsPage extends BasePage {
  NotificationsPage(WidgetTester tester) : super(tester);

  // ── Navigation ─────────────────────────────────────────────────────────────
  Future<void> tapNotificationIcon()  async => await tapByKey(homeNotificationsButton);
  Future<void> tapBack()              async => await tapByKey(notificationsBackButton);

  // ── Scroll ─────────────────────────────────────────────────────────────────
  Future<void> scrollDown() async {
    await tester.drag(find.byKey(const Key(notificationsListView)), const Offset(0, -400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  Future<void> scrollUp() async {
    await tester.drag(find.byKey(const Key(notificationsListView)), const Offset(0, 400));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  // ── Filter ─────────────────────────────────────────────────────────────────
  Future<void> tapFilterIcon()              async => await tapByKey(notificationsFilterIcon);
  Future<void> tapFilterComments()          async => await tapByKey(notificationsFilterComments);
  Future<void> tapFilterLikes()             async => await tapByKey(notificationsFilterLikes);
  Future<void> tapFilterFollowing()         async => await tapByKey(notificationsFilterFollowing);
  Future<void> tapFilterReposts()           async => await tapByKey(notificationsFilterReposts);
  Future<void> tapFilterShowAll()           async => await tapByKey(notificationsFilterShowAll);

  // ── Tap first notification in list ─────────────────────────────────────────
  Future<void> tapFirstNotification() async {
    final finder = find.byKey(const Key(notificationTileInkwell));

    if (finder.evaluate().isEmpty) {
      debugPrint('tapFirstNotification: no notification tiles found, skipping');
      return;
    }
    debugPrint('tapFirstNotification: found ${finder.evaluate().length} tiles, tapping first');
    await tester.tap(finder.first, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  // ── Visibility checks ──────────────────────────────────────────────────────
  bool isNotificationsScreenVisible() => isVisible(notificationsScreenKey);
  bool isHomePageVisible()            => isVisible(homeScaffold);

  // ── Filter result checks ───────────────────────────────────────────────────
  // After applying a filter the screen is valid if EITHER:
  // - the list has results (notificationsListKey visible), OR
  // - the empty-filter message is shown (no notifications of that type)
  // Both mean the filter was applied successfully.
  bool isFilterAppliedSuccessfully() =>
      isVisible(notificationsListKey) ||
      find.text('Switch to showing all to see recent notifications')
          .evaluate().isNotEmpty;

  bool hasNotificationItems() =>
    find.byKey(const Key(notificationTileInkwell)).evaluate().isNotEmpty;

  bool isOnTrackPage()   => isVisible(behindTheTrackBackButton);
  bool isOnProfilePage() => isVisible(profileAvatarGesture);
}