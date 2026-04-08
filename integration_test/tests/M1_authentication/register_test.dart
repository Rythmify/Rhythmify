import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/auth/register_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Registration', () {

    // ─── Valid Registration ─────────────────────────────────────────────────
    testWidgets('should register successfully with new valid credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
      await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Complete registration
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

      // Verify home page is visible
      expect(registerPage.isOnHomePage(), true);
    });

    testWidgets('should scroll and select the right values and register successfully', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
      await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Manual step-by-step registration with scrolling
      await registerPage.enterEmail(newUser.email);
      await registerPage.tapContinue();
      await tester.pumpAndSettle();

      await registerPage.enterPassword(newUser.password);
      await registerPage.tapPasswordContinue();
      await tester.pumpAndSettle();

      await registerPage.enterUsername(newUser.username);
      await registerPage.selectMonth(newUser.month);
      await registerPage.openDayDropdown();
      await registerPage.scrollToDay(ScrollValues.days);
      expect(find.text(ScrollValues.days), findsOneWidget);

      await registerPage.selectDay(newUser.day);
      
      await registerPage.openYearDropdown();
      await registerPage.scrollToYear(ScrollValues.years);
      expect(find.text(ScrollValues.years), findsOneWidget);

      await registerPage.selectYear(newUser.year);
      await registerPage.selectGender(newUser.gender);
      await registerPage.tapFinalContinue();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(registerPage.isOnHomePage(), true);
    });


    // ─── Existing Email ──────────────────────────────────────────────────
    testWidgets('should show error when registering with existing email', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
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
    });


    // ─── Invalid Email Format ────────────────────────────────────────────
    testWidgets('should show error when registering with invalid email format', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
      await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await registerPage.enterEmail('invalid-email');
      await registerPage.tapContinue();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(registerPage.isInvalidEmailErrorVisible(), true);
    });


    // ─── Invalid Password Format ─────────────────────────────────────────
    for (final invalidPassword in invalidPasswords) {
      testWidgets(
        'should show error when registering with invalid password: ${invalidPassword.reason}',
        (tester) async {
          app.main();
          await tester.pumpAndSettle(const Duration(seconds: 5));

          final registerPage = RegisterPage(tester);

          // Navigate to register
          await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
          await tester.pumpAndSettle(const Duration(seconds: 3));

          await registerPage.enterEmail(newUser.email);
          await registerPage.tapContinue();
          await tester.pumpAndSettle();

          await registerPage.enterPassword(invalidPassword.password);
          await registerPage.tapPasswordContinue();
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(
            registerPage.isSpecificPasswordErrorVisible(invalidPassword.errorKey),
            true,
            reason: 'Expected error for ${invalidPassword.reason}',
          );
        },
      );
    }


    // ─── Empty Fields Validation ────────────────────────────────────────
    testWidgets('should show error when registering with empty email', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
      await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await registerPage.enterEmail('');
      await registerPage.tapContinue();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(registerPage.isEmailEmptyErrorVisible(), true);
    });

    testWidgets('should show error when registering with empty password', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
      await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await registerPage.enterEmail(newUser.email);
      await registerPage.tapContinue();
      await tester.pumpAndSettle();

      await registerPage.enterPassword('');
      await registerPage.tapPasswordContinue();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(registerPage.isPasswordEmptyErrorVisible(), true);
    });

    testWidgets('should show error when registering with empty username', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
      await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await registerPage.enterEmail(newUser.email);
      await registerPage.tapContinue();
      await tester.pumpAndSettle();

      await registerPage.enterPassword(newUser.password);
      await registerPage.tapPasswordContinue();
      await tester.pumpAndSettle();

      await registerPage.enterUsername('');
      await registerPage.selectMonth(newUser.month);
      await registerPage.selectDay(newUser.day);
      await registerPage.selectYear(newUser.year);
      await registerPage.selectGender(newUser.gender);
      await registerPage.tapFinalContinue();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(registerPage.isUsernameEmptyErrorVisible(), true);
    });

    testWidgets('should show error when registering with empty month', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
      await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await registerPage.enterEmail(newUser.email);
      await registerPage.tapContinue();
      await tester.pumpAndSettle();

      await registerPage.enterPassword(newUser.password);
      await registerPage.tapPasswordContinue();
      await tester.pumpAndSettle();

      await registerPage.enterUsername(newUser.username);
      // Skip month selection
      await registerPage.selectDay(newUser.day);
      await registerPage.selectYear(newUser.year);
      await registerPage.selectGender(newUser.gender);
      await registerPage.tapFinalContinue();
      await tester.pumpAndSettle();

      expect(registerPage.isDateOfBirthEmptyErrorVisible(), true);
    });

    testWidgets('should show error when registering with empty day', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
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
      // Skip day selection
      await registerPage.selectYear(newUser.year);
      await registerPage.selectGender(newUser.gender);
      await registerPage.tapFinalContinue();
      await tester.pumpAndSettle();

      expect(registerPage.isDateOfBirthEmptyErrorVisible(), true);
    });

    testWidgets('should show error when registering with empty year', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
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
      // Skip year selection
      await registerPage.selectGender(newUser.gender);
      await registerPage.tapFinalContinue();
      await tester.pumpAndSettle();

      expect(registerPage.isDateOfBirthEmptyErrorVisible(), true);
    });

    testWidgets('should show error when registering with empty gender', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
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
      // Skip gender selection
      await registerPage.tapFinalContinue();
      await tester.pumpAndSettle();

      expect(registerPage.isGenderEmptyErrorVisible(), true);
    });


    // ─── Age Restriction ───────────────────────────────────────────────────
    testWidgets('should show error when registering with age below 13', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final registerPage = RegisterPage(tester);

      // Navigate to register
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
    });


    // ─── Social Authentication (SKIPPED - Ready for Backend Integration) ────
    // testWidgets(
    //   'should register successfully with Google authentication',
    //   (tester) async {
    //     app.main();
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     final registerPage = RegisterPage(tester);

    //     // Navigate to sign-in page (social buttons are on sign-in page)
    //     await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 3));

    //     // Tap Google Sign-In button for registration
    //     await tester.tap(find.byKey(const Key(authSocialGoogleButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     // Verify home page is reached (successful registration)
    //     expect(registerPage.isOnHomePage(), true);
    //   },
    // );

    // testWidgets(
    //   'should register successfully with Facebook authentication',
    //   (tester) async {
    //     app.main();
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     final registerPage = RegisterPage(tester);

    //     // Navigate to sign-in page (social buttons are on sign-in page)
    //     await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 3));

    //     // Tap Facebook Sign-In button for registration
    //     await tester.tap(find.byKey(const Key(authSocialFacebookButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     // Verify home page is reached (successful registration)
    //     expect(registerPage.isOnHomePage(), true);
    //   },
    // );

    // testWidgets(
    //   'should register successfully with Apple authentication',
    //   (tester) async {
    //     app.main();
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     final registerPage = RegisterPage(tester);

    //     // Navigate to sign-in page (social buttons are on sign-in page)
    //     await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 3));

    //     // Tap Apple Sign-In button for registration
    //     await tester.tap(find.byKey(const Key(authSocialAppleButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     // Verify home page is reached (successful registration)
    //     expect(registerPage.isOnHomePage(), true);
    //   },
    // );

    // testWidgets(
    //   'should handle Google authentication registration with invalid credentials',
    //   (tester) async {
    //     app.main();
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     final registerPage = RegisterPage(tester);

    //     // Navigate to sign-in page
    //     await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 3));

    //     // Attempt Google Sign-In with invalid credentials
    //     await tester.tap(find.byKey(const Key(authSocialGoogleButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     // Should show error or return to sign-in page
    //     expect(
    //       registerPage.isOnLoginPage() || find.text('Authentication failed').evaluate().isNotEmpty,
    //       true,
    //     );
    //   },
    // );

    // testWidgets(
    //   'should handle Facebook authentication registration with invalid credentials',
    //   (tester) async {
    //     app.main();
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     final registerPage = RegisterPage(tester);

    //     // Navigate to sign-in page
    //     await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 3));

    //     // Attempt Facebook Sign-In with invalid credentials
    //     await tester.tap(find.byKey(const Key(authSocialFacebookButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     // Should show error or return to sign-in page
    //     expect(
    //       registerPage.isOnLoginPage() || find.text('Authentication failed').evaluate().isNotEmpty,
    //       true,
    //     );
    //   },
    // );

    // testWidgets(
    //   'should handle Apple authentication registration with invalid credentials',
    //   (tester) async {
    //     app.main();
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     final registerPage = RegisterPage(tester);

    //     // Navigate to sign-in page
    //     await tester.tap(find.byKey(const Key(onboardingCreateAccountButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 3));

    //     // Attempt Apple Sign-In with invalid credentials
    //     await tester.tap(find.byKey(const Key(authSocialAppleButton)));
    //     await tester.pumpAndSettle(const Duration(seconds: 5));

    //     // Should show error or return to sign-in page
    //     expect(
    //       registerPage.isOnLoginPage() || find.text('Authentication failed').evaluate().isNotEmpty,
    //       true,
    //     );
    //   },
    // );
  });
}
