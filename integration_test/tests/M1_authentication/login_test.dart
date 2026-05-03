import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/login_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M1 - Authentication: Login - all scenarios', (tester) async {
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

    // ── Helper to reset to onboarding between scenarios ──
    Future<void> goBackToOnboarding() async {
      final NavigatorState navigator = tester.state(find.byType(Navigator).last);
      navigator.popUntil((route) => route.isFirst);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    
    await tryTest('TC-AUTH-LOGIN-001 | error message when enter empty email', () async {
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.tapContinue();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Please enter your email'), findsOneWidget);
      await goBackToOnboarding();
    });

    await tryTest('TC-AUTH-LOGIN-002 | error message when enter empty password', () async {
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.enterEmail(validEmail);
      await loginPage.tapContinue();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.tapLogin();
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.text('Please enter your password'), findsOneWidget);

      await goBackToOnboarding();
    });

    await tryTest('TC-AUTH-LOGIN-003 | error message when enter invalid email format', () async {
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.enterEmail('invalid-email-format');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await loginPage.tapContinue();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Please enter a valid email'), findsOneWidget);

      await goBackToOnboarding();
  });

    await tryTest('TC-AUTH-LOGIN-004 | error message when enter invalid password', () async {
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.enterEmail(validEmail);
      await loginPage.tapContinue();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.enterPassword('1234');
      await loginPage.tapLogin();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Invalid email or password.'), findsOneWidget);
      expect(loginPage.isOnPasswordPage(), true);

      await goBackToOnboarding();
    });
    
    await tryTest('TC-AUTH-LOGIN-005 | error message when login with unregister email', () async {
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await loginPage.login('unregistered@rythmify.com', validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Invalid email or password.'), findsOneWidget);
    expect(loginPage.isOnPasswordPage(), true);

    await goBackToOnboarding();
    });

    await tryTest('TC-AUTH-LOGIN-006 | Login Successfully', () async {
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.login(validEmail, validPassword);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(loginPage.isOnHomePage(), true);
    });

    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}