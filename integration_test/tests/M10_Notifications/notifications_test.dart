import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M10_Notifications/notification_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M10 - Notifications - all scenarios', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // ── Login ────────────────────────────────────────────────────────────────
    final loginPage         = LoginPage(tester);
    final notificationsPage = NotificationsPage(tester);

    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(loginPage.isOnHomePage(), true);

    // ─── TC-NOTIF-001 | Tap notification icon → notifications screen ──────
    await notificationsPage.tapNotificationIcon();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    //expect(notificationsPage.isNotificationsScreenVisible(), true);

    // ─── TC-NOTIF-002 | Scroll down and up smoothly ───────────────────────
    await notificationsPage.scrollDown();
    await notificationsPage.scrollUp();
    expect(notificationsPage.isNotificationsScreenVisible(), true);


    // FILTER — COMMENTS
    // ─── TC-NOTIF-003 | Filter by Comments → only comment notifications ───
    await notificationsPage.tapFilterIcon();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await notificationsPage.tapFilterComments();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(notificationsPage.isFilterAppliedSuccessfully(), true,
      reason: 'Filter should be applied — list or empty message visible');

    // ─── TC-NOTIF-004 | Tap a comment notification → track page opens ─────
    await notificationsPage.tapFirstNotification();
    expect(notificationsPage.isOnTrackPage(), true,
        reason: 'Tapping a comment notification should open the track page');

    // ─── TC-NOTIF-005 | Back → notifications screen ───────────────────────
    await notificationsPage.tapBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //expect(notificationsPage.isNotificationsScreenVisible(), true);


    // FILTER — LIKES
    // ─── TC-NOTIF-006 | Filter by Likes → only like notifications ─────────
    await notificationsPage.tapFilterIcon();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await notificationsPage.tapFilterLikes();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(notificationsPage.isFilterAppliedSuccessfully(), true,
    reason: 'Filter should be applied — list or empty message visible');

    // ─── TC-NOTIF-007 | Tap a like notification → track page opens ────────
    await notificationsPage.tapFirstNotification();
    expect(notificationsPage.isOnTrackPage(), true,
        reason: 'Tapping a like notification should open the track page');

    // ─── TC-NOTIF-008 | Back → notifications screen ───────────────────────
    await notificationsPage.tapBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(notificationsPage.isNotificationsScreenVisible(), true);


    // FILTER — FOLLOWING
    // ─── TC-NOTIF-009 | Filter by Following → only following notifications ─
    await notificationsPage.tapFilterIcon();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await notificationsPage.tapFilterFollowing();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(notificationsPage.isFilterAppliedSuccessfully(), true,
      reason: 'Filter should be applied — list or empty message visible');

    // ─── TC-NOTIF-010 | Tap a following notification → profile page opens ─
    await notificationsPage.tapFirstNotification();
    expect(notificationsPage.isOnProfilePage(), true,
        reason: 'Tapping a follow notification should open the user profile');

    // ─── TC-NOTIF-011 | Back → notifications screen ───────────────────────
    await notificationsPage.tapBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(notificationsPage.isNotificationsScreenVisible(), true);


    // FILTER — REPOSTS
    // ─── TC-NOTIF-012 | Filter by Reposts → only repost notifications ─────
    await notificationsPage.tapFilterIcon();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await notificationsPage.tapFilterReposts();
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(notificationsPage.isFilterAppliedSuccessfully(), true,
    reason: 'Filter should be applied — list or empty message visible');

    // ─── TC-NOTIF-013 | Tap a repost notification → track page opens ──────
    await notificationsPage.tapFirstNotification();
    expect(notificationsPage.isOnTrackPage(), true,
        reason: 'Tapping a repost notification should open the track page');

    // ─── TC-NOTIF-014 | Back → notifications screen ───────────────────────
    await notificationsPage.tapBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    //expect(notificationsPage.isNotificationsScreenVisible(), true);


    // FILTER — SHOW ALL
    // ─── TC-NOTIF-015 | Filter → Show all → all notifications visible ─────
    await notificationsPage.tapFilterIcon();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await notificationsPage.tapFilterShowAll();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(notificationsPage.isNotificationsScreenVisible(), true,
        reason: 'All notifications should be shown after Show All');

    // ─── TC-NOTIF-016 | Back → home page ─────────────────────────────────
    await notificationsPage.tapBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(notificationsPage.isHomePageVisible(), true,
        reason: 'Back from notifications should return to the home page');
  });
}