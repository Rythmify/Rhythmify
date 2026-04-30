import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../pages/M14_Premium/premium_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TC-PLAYER-001 | Full player — all checks', (tester) async {
    app.main();
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('[Test] Suppressed: ${details.exception}');
    };
    final List<String> failures = [];
    Future<void> tryTest(String name, Future<void> Function() body) async {
      try {
        await body();
        debugPrint('[PASS] $name');
      } catch (e) {
        failures.add('❌ $name\n   → $e');
        debugPrint('[FAIL] $name: $e');
      }
    }
    await tester.pumpAndSettle(const Duration(seconds: 5));

    final loginPage = LoginPage(tester);
    final premiumPage = PremiumPage(tester);

    // ── Login ──────────────────────────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(loginPage.isOnHomePage(), true);


    // ─── TC-PREMIUM-001 | Navigate to Upgrade tab ─────────────────────────
    await tryTest('TC-PREMIUM-001 | Navigate to Upgrade tab', () async {
      await premiumPage.tapUpgradeNavButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    await tryTest('TC-PREMIUM-002 | Check Buttons Visibility (continue/see all plans)', () async {
      expect(premiumPage.isButtonsVisible(), true); 
    });

    await tryTest('TC-PREMIUM-003 | Continue button --> Confirm payment scenario', () async {
      await premiumPage.tapContinueButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await premiumPage.tapConfirmPaymentButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));    
      await premiumPage.tapStartExploring();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    await tryTest('TC-PREMIUM-004 | See All Plans button', () async {
      await premiumPage.tapSeeAllPlansButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await premiumPage.scrollHorizontallyInSection(PremiumPlansSection);
      await tester.pumpAndSettle(const Duration(seconds: 3));    
      await premiumPage.scrollUntilVisible(itemText: 'Manage subscribtion', scrollableKey: PremiumManageSubscribtionButton);
      await premiumPage.tapMangeSubscribtionButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await premiumPage.scrollUntilVisible(itemText: 'cancel subscribtion', scrollableKey: PremiumCancelsubscribtionButton);
      await premiumPage.tapKeepsubscribtionButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await premiumPage.tapCancelSubscribtionButton();
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });


    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}