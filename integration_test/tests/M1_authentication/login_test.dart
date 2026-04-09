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
    await tester.pumpAndSettle(const Duration(seconds: 5));
    final loginPage = LoginPage(tester);

    // ── Helper to reset to onboarding between scenarios ──
    Future<void> goBackToOnboarding() async {
      final NavigatorState navigator = tester.state(find.byType(Navigator).last);
      navigator.popUntil((route) => route.isFirst);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    // ─── 1. Empty email ───────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await loginPage.tapContinue();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Please enter your email'), findsOneWidget);

    await goBackToOnboarding();

    // ─── 2. Empty password ────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await loginPage.enterEmail(validEmail);
    await loginPage.tapContinue();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await loginPage.tapLogin();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Please enter your password'), findsOneWidget);

    await goBackToOnboarding();

    // ─── 3. Invalid email format ──────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await loginPage.enterEmail('invalid-email-format');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await loginPage.tapContinue();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Please enter a valid email'), findsOneWidget);

    await goBackToOnboarding();

    // ─── 4. Invalid passwords (loop) ─────────────────────────────────
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
    

    // ─── 5. Unregistered email ────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await loginPage.login('unregistered@rythmify.com', validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Invalid email or password.'), findsOneWidget);
    expect(loginPage.isOnPasswordPage(), true);

    await goBackToOnboarding();

    // ─── 6. Valid login (last) ────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingLoginButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await loginPage.login(validEmail, validPassword);
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(loginPage.isOnHomePage(), true);
  });
}