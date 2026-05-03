import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../base_page.dart';
import '../../selectors/selectors.dart';

class NotificationsPage extends BasePage {
  NotificationsPage(WidgetTester tester) : super(tester);

  // ── Navigation ─────────────────────────────────────────────────────────────
  Future<void> tapNotificationIcon()  async => await tapByKey(homeNotificationsButton);
  Future<void> tapBack()              async => await tapByKey(notificationsBackButton);
  Future<void> tapTrackPageBack()     async => await tapByKey(behindTheTrackBackButton);
  Future<void> tapProfilePageBack()   async => await tapByKey(publicProfileBackButton);

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
  Future<void> tapFilterIcon() async {
    await tapByKey(notificationsFilterIcon);
    await tester.pumpAndSettle(const Duration(seconds: 1));
  } 
  Future<void> tapFilterComments() async {
    await tapByKey(notificationsFilterComments);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  Future<void> tapFilterLikes()  async {
    await tapByKey(notificationsFilterLikes);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  Future<void> tapFilterFollowing() async {
    await tapByKey(notificationsFilterFollowing);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  } 
  Future<void> tapFilterReposts()  async {
    await tapByKey(notificationsFilterReposts);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  Future<void> tapFilterReactions()  async {
    await tapByKey(notificationsFilterReactions);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  Future<void> tapFilterShowAll() async {
    await tapByKey(notificationsFilterShowAll);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  // ── Tap first notification in list ─────────────────────────────────────────
  Future<void> tapFirstNotification() async {
    final finder = find.byKey(const Key(notificationTileInkwell));

    if (finder.evaluate().isEmpty) {
      debugPrint('tapFirstNotification: no notification tiles found, skipping');
      return;
    }
    debugPrint('tapFirstNotification: found ${finder.evaluate().length} tiles, tapping first');
    // ensure the first tile is scrolled into view before tapping
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(finder.first, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }

  Future<void> waitForNotificationsToLoad() async {
    // first wait for bottom sheet to fully dismiss (filter button reappears)
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      final filterVisible = find
          .byKey(const Key(notificationsFilterIcon))
          .evaluate()
          .isNotEmpty;
      debugPrint('waitForNotifications: filterVisible=$filterVisible');
      if (filterVisible) break;
    }

    // then wait for tiles or empty state
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));

      final isLoading = find
          .byKey(const Key(notificationsLoadingIndicator))
          .evaluate()
          .isNotEmpty;

      final hasTiles = find
          .byKey(const Key(notificationTileInkwell))
          .evaluate()
          .isNotEmpty;

      final isEmpty = find
          .text('Switch to showing all to see recent notifications')
          .evaluate()
          .isNotEmpty;

      debugPrint('waitForNotifications: loading=$isLoading tiles=$hasTiles empty=$isEmpty');

      if (!isLoading && (hasTiles || isEmpty)) break;
    }

    await tester.pumpAndSettle(const Duration(seconds: 1));
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

  bool hasNotificationItems() {
    final count = find.byKey(const Key(notificationTileInkwell)).evaluate().length;
    debugPrint('hasNotificationItems: $count tiles found');
    return count > 0;
  }

  bool isOnTrackPage()   => isVisible(behindTheTrackBackButton);
  bool isOnProfilePage() => isVisible(profileAvatarGesture);
}