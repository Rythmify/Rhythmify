import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/M1_Authentication/register_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('M1 - Authentication: Registration - all scenarios', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));
    final registerPage = RegisterPage(tester);

    Future<void> goBackToOnboarding() async {
      final NavigatorState navigator = tester.state(find.byType(Navigator).last);
      navigator.popUntil((route) => route.isFirst);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    // ─── 1. Empty email ───────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.tapContinue();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(registerPage.isEmailEmptyErrorVisible(), true);
    await goBackToOnboarding();

    // ─── 2. Invalid email format ──────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.enterEmail('invalid-email');
    await registerPage.tapContinue();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(registerPage.isInvalidEmailErrorVisible(), true);
    await goBackToOnboarding();

    // ─── 3. Empty password ────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.enterEmail(newUser.email);
    await registerPage.tapContinue();
    await tester.pumpAndSettle();

    await registerPage.tapPasswordContinue();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(registerPage.isPasswordEmptyErrorVisible(), true);
    await goBackToOnboarding();

    // ─── 4. Invalid passwords ─────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.enterEmail(newUser.email);
    await registerPage.tapContinue();
    await tester.pumpAndSettle();

    for (final invalidPassword in invalidPasswords) {
      await registerPage.enterPassword(invalidPassword.password);
      await registerPage.tapPasswordContinue();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(
        registerPage.isSpecificPasswordErrorVisible(invalidPassword.errorKey),
        true,
        reason: 'Expected error for ${invalidPassword.reason}',
      );

      // Clear the password field before trying the next one
      await tester.enterText(
        find.byKey(const Key(authPasswordTextField)),
        '',
      );
      await tester.pumpAndSettle();
    }
    await goBackToOnboarding();

    // ─── 5. Empty username ────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.enterEmail(newUser.email);
    await registerPage.tapContinue();
    await tester.pumpAndSettle();
    await registerPage.enterPassword(newUser.password);
    await registerPage.tapPasswordContinue();
    await tester.pumpAndSettle();

    await registerPage.selectMonth(newUser.month);
    await registerPage.selectDay(newUser.day);
    await registerPage.selectYear(newUser.year);
    await registerPage.selectGender(newUser.gender);
    await registerPage.tapFinalContinue();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(registerPage.isUsernameEmptyErrorVisible(), true);
    await goBackToOnboarding();

    // ─── 6. Empty month ───────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.enterEmail(newUser.email);
    await registerPage.tapContinue();
    await tester.pumpAndSettle();
    await registerPage.enterPassword(newUser.password);
    await registerPage.tapPasswordContinue();
    await tester.pumpAndSettle();

    await registerPage.enterUsername(newUser.username);
    await registerPage.selectDay(newUser.day);
    await registerPage.selectYear(newUser.year);
    await registerPage.selectGender(newUser.gender);
    await registerPage.tapFinalContinue();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(registerPage.isDateOfBirthEmptyErrorVisible(), true);
    await goBackToOnboarding();

    // ─── 7. Empty day ─────────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.enterEmail(newUser.email);
    await registerPage.tapContinue();
    await tester.pumpAndSettle();
    await registerPage.enterPassword(newUser.password);
    await registerPage.tapPasswordContinue();
    await tester.pumpAndSettle();

    await registerPage.enterUsername(newUser.username);
    await registerPage.selectMonth(newUser.month);
    await registerPage.selectYear(newUser.year);
    await registerPage.selectGender(newUser.gender);
    await registerPage.tapFinalContinue();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(registerPage.isDateOfBirthEmptyErrorVisible(), true);
    await goBackToOnboarding();

    // ─── 8. Empty year ────────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.enterEmail(newUser.email);
    await registerPage.tapContinue();
    await tester.pumpAndSettle();
    await registerPage.enterPassword(newUser.password);
    await registerPage.tapPasswordContinue();
    await tester.pumpAndSettle();

    await registerPage.enterUsername(newUser.username);
    await registerPage.selectMonth(newUser.month);
    await registerPage.selectDay(newUser.day);
    await registerPage.selectGender(newUser.gender);
    await registerPage.tapFinalContinue();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(registerPage.isDateOfBirthEmptyErrorVisible(), true);
    await goBackToOnboarding();

    // ─── 9. Empty gender ──────────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.enterEmail(newUser.email);
    await registerPage.tapContinue();
    await tester.pumpAndSettle();
    await registerPage.enterPassword(newUser.password);
    await registerPage.tapPasswordContinue();
    await tester.pumpAndSettle();

    await registerPage.enterUsername(newUser.username);
    await registerPage.selectMonth(newUser.month);
    await registerPage.selectDay(newUser.day);
    await registerPage.selectYear(newUser.year);
    await registerPage.tapFinalContinue();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(registerPage.isGenderEmptyErrorVisible(), true);
    await goBackToOnboarding();

    // ─── 10. Age restriction ──────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.register(
      ageRestrictedUser.email,
      ageRestrictedUser.password,
      ageRestrictedUser.username,
      ageRestrictedUser.month,
      ageRestrictedUser.day,
      ageRestrictedUser.year,
      ageRestrictedUser.gender,
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(registerPage.isAgeRestrictionErrorVisible(), true);
    await goBackToOnboarding();

    // ─── 11. Existing email ───────────────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.register(
      existingUser.email,
      existingUser.password,
      existingUser.username,
      existingUser.month,
      existingUser.day,
      existingUser.year,
      existingUser.gender,
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(registerPage.isAlreadyExistsErrorVisible(), true);
    await goBackToOnboarding();

    // ─── 12. Valid registration (last) ────────────────────────────────
    await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await registerPage.register(
      newUser.email,
      newUser.password,
      newUser.username,
      newUser.month,
      newUser.day,
      newUser.year,
      newUser.gender,
    );
    await tester.pumpAndSettle(const Duration(seconds: 5));
    //expect(registerPage.isOnValidEmailPage(), true); 
  });
}