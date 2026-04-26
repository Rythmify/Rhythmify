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
    final firstNotification = find.byWidgetPredicate(
      (widget) =>
          widget.key != null &&
          widget.key.toString().contains('notification_item_'),
    );
    await tester.tap(firstNotification.first);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  // ── Visibility checks ──────────────────────────────────────────────────────
  bool isNotificationsScreenVisible() => isVisible(notificationsScreenKey);
  bool isHomePageVisible()            => isVisible(homeScaffold);

  // ── Filter result checks ───────────────────────────────────────────────────
  /// Verifies that every visible notification item belongs to [expectedType].
  /// expectedType matches against the key pattern: notification_item_{type}_{id}
  bool areOnlyFilteredNotificationsVisible(String expectedType) {
    final allNotifications = find.byWidgetPredicate(
      (widget) =>
          widget.key != null &&
          widget.key.toString().contains('notification_item_'),
    );

    if (allNotifications.evaluate().isEmpty) return false;

    return allNotifications.evaluate().every(
      (element) => element.widget.key.toString().contains(expectedType),
    );
  }

  bool isOnTrackPage()   => isVisible(behindTheTrackBackButton);
  bool isOnProfilePage() => isVisible(profileAvatarGesture);
}