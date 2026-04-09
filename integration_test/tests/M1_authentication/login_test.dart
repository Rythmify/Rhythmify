import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/auth/login_page.dart';
import '../../fixtures/test_data.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('M1 - Authentication: Login', () {

    // ─── Page Load Tests ────────────────────────────────────────────────────
    testWidgets('onboarding login button is visible and navigates to sign-in page', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final loginPage = LoginPage(tester);
      expect(find.byKey(const Key(onboardingLoginButton)), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);

      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(loginPage.isOnLoginPage(), true);
      expect(find.text('Sign in or create an account'), findsOneWidget);
    });

    testWidgets('login page loads correctly with all social auth buttons', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final loginPage = LoginPage(tester);
      expect(loginPage.isOnLoginPage(), true);
      expect(find.byKey(const Key(authSocialGoogleButton)), findsOneWidget);
      expect(find.byKey(const Key(authSocialAppleButton)), findsOneWidget);
      expect(find.byKey(const Key(authSocialFacebookButton)), findsOneWidget);
      expect(find.byKey(const Key(authContinueButton)), findsOneWidget);
    });


    // ─── Valid Credentials ──────────────────────────────────────────────────
    testWidgets('should login successfully with valid credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final loginPage = LoginPage(tester);
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.login(validEmail, validPassword);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(loginPage.isOnHomePage(), true);
    });


    // ─── Invalid Credentials ────────────────────────────────────────────────
    // Test multiple invalid password scenarios for authentication errors
    for (final invalidPassword in ['WrongPassword1!', 'completelywrong', '12345678']) {
      testWidgets('should show error message with invalid password: $invalidPassword', (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 5));

        final loginPage = LoginPage(tester);
        await tester.tap(find.byKey(const Key(onboardingLoginButton)));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await loginPage.enterEmail(validEmail);
        await loginPage.tapContinue();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await loginPage.enterPassword(invalidPassword);
        await loginPage.tapLogin();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.text('Invalid email or password.'), findsOneWidget);
        expect(loginPage.isOnPasswordPage(), true);
      });
    }

    testWidgets('should show error with unregistered email', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final loginPage = LoginPage(tester);
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.login('unregistered@rythmify.com', validPassword);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Invalid email or password.'), findsOneWidget);
      expect(loginPage.isOnPasswordPage(), true);
    });

    testWidgets('should show error with invalid email format', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final loginPage = LoginPage(tester);
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.enterEmail('invalid-email-format');
      await loginPage.tapContinue();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });


    // ─── Empty Fields Validation ────────────────────────────────────────────
    testWidgets('should show error with empty email', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final loginPage = LoginPage(tester);
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.tapContinue();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should show error with empty password', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final loginPage = LoginPage(tester);
      await tester.tap(find.byKey(const Key(onboardingLoginButton)));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.enterEmail(validEmail);
      await loginPage.tapContinue();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await loginPage.tapLogin();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Please enter your password'), findsOneWidget);
    });


    // ─── Social Authentication (SKIPPED - Ready for Backend Integration) ────
  //   testWidgets(
  //     'should login successfully with Google authentication',
  //     (tester) async {
  //       app.main();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       final loginPage = LoginPage(tester);
  //       await tester.tap(find.byKey(const Key(onboardingLoginButton)));
  //       await tester.pumpAndSettle(const Duration(seconds: 3));

  //       // Tap Google Sign-In button
  //       await loginPage.tapGoogleSignIn();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       // Verify home page is reached
  //       expect(loginPage.isOnHomePage(), true);
  //     },
  //   );

  //   testWidgets(
  //     'should login successfully with Facebook authentication',
  //     (tester) async {
  //       app.main();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       final loginPage = LoginPage(tester);
  //       await tester.tap(find.byKey(const Key(onboardingLoginButton)));
  //       await tester.pumpAndSettle(const Duration(seconds: 3));

  //       // Tap Facebook Sign-In button
  //       await loginPage.tapFacebookSignIn();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       // Verify home page is reached
  //       expect(loginPage.isOnHomePage(), true);
  //     },
  //   );

  //   testWidgets(
  //     'should login successfully with Apple authentication',
  //     (tester) async {
  //       app.main();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       final loginPage = LoginPage(tester);
  //       await tester.tap(find.byKey(const Key(onboardingLoginButton)));
  //       await tester.pumpAndSettle(const Duration(seconds: 3));

  //       // Tap Apple Sign-In button
  //       await loginPage.tapAppleSignIn();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       // Verify home page is reached
  //       expect(loginPage.isOnHomePage(), true);
  //     },
  //   );

  //   testWidgets(
  //     'should handle Google authentication with invalid credentials',
  //     (tester) async {
  //       app.main();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       final loginPage = LoginPage(tester);
  //       await tester.tap(find.byKey(const Key(onboardingLoginButton)));
  //       await tester.pumpAndSettle(const Duration(seconds: 3));

  //       // Attempt Google Sign-In with invalid credentials
  //       await loginPage.tapGoogleSignIn();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       // Should show error or return to login page
  //       expect(
  //         loginPage.isOnLoginPage() || find.text('Authentication failed').evaluate().isNotEmpty,
  //         true,
  //       );
  //     },
  //   );

  //   testWidgets(
  //     'should handle Facebook authentication with invalid credentials',
  //     (tester) async {
  //       app.main();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       final loginPage = LoginPage(tester);
  //       await tester.tap(find.byKey(const Key(onboardingLoginButton)));
  //       await tester.pumpAndSettle(const Duration(seconds: 3));

  //       // Attempt Facebook Sign-In with invalid credentials
  //       await loginPage.tapFacebookSignIn();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       // Should show error or return to login page
  //       expect(
  //         loginPage.isOnLoginPage() || find.text('Authentication failed').evaluate().isNotEmpty,
  //         true,
  //       );
  //     },
  //   );

  //   testWidgets(
  //     'should handle Apple authentication with invalid credentials',
  //     (tester) async {
  //       app.main();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       final loginPage = LoginPage(tester);
  //       await tester.tap(find.byKey(const Key(onboardingLoginButton)));
  //       await tester.pumpAndSettle(const Duration(seconds: 3));

  //       // Attempt Apple Sign-In with invalid credentials
  //       await loginPage.tapAppleSignIn();
  //       await tester.pumpAndSettle(const Duration(seconds: 5));

  //       // Should show error or return to login page
  //       expect(
  //         loginPage.isOnLoginPage() || find.text('Authentication failed').evaluate().isNotEmpty,
  //         true,
  //       );
  //     },
  //   );
  });
}