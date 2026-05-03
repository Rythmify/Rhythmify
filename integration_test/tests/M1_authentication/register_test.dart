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
    final registerPage = RegisterPage(tester);

    Future<void> goBackToOnboarding() async {
      final NavigatorState navigator = tester.state(find.byType(Navigator).last);
      navigator.popUntil((route) => route.isFirst);
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    await tryTest('TC-AUTH-REGISTER-001 | error message when enter empty email', () async {
      await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await registerPage.tapContinue();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(registerPage.isEmailEmptyErrorVisible(), true);
      await goBackToOnboarding();
    });

    await tryTest('TC-AUTH-REGISTER-002 | error message when enter invalid email format', () async {
      await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await registerPage.enterEmail('invalid-email');
      await registerPage.tapContinue();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(registerPage.isInvalidEmailErrorVisible(), true);
      await goBackToOnboarding();
    });

    await tryTest('TC-AUTH-REGISTER-003 | error message when enter empty password', () async {
      await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await registerPage.enterEmail(newUser.email);
      await registerPage.tapContinue();
      await tester.pumpAndSettle();

      await registerPage.tapPasswordContinue();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(registerPage.isPasswordEmptyErrorVisible(), true);
      await goBackToOnboarding();
    });

    await tryTest('TC-AUTH-REGISTER-004 | error message when enter invalid password format (too short/no UpperCase/no LowerCase/ <8 Char)', () async {
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
    });


   await tryTest('TC-AUTH-REGISTER-005 | error message when enter empty Display name', () async {
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
   });

    await tryTest('TC-AUTH-REGISTER-006 | error message when enter empty Month', () async {
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
    });

    await tryTest('TC-AUTH-REGISTER-007 | error message when enter empty Day', () async {
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
    });

    
    await tryTest('TC-AUTH-REGISTER-008 | error message when enter empty Year', () async {
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
    });

    await tryTest('TC-AUTH-REGISTER-009 | error message when enter empty gender', () async {
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
    });

    await tryTest('TC-AUTH-REGISTER-010 | error message if age < 13', () async {
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
    });

    await tryTest('TC-AUTH-REGISTER-011 | error message when register with existing email', () async {
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
    });

    await tryTest('TC-AUTH-REGISTER-012 | Register Successfully', () async {
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

    FlutterError.onError = originalOnError;
    if (failures.isNotEmpty) {
      final summary = failures.join('\n');
      debugPrint('\n══ TEST SUMMARY ══\n$summary');
      fail('${failures.length} test(s) failed:\n$summary');
    }
  });
}