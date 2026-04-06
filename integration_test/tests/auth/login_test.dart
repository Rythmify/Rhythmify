import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rythmify/main.dart' as app;
import '../../pages/auth/login_page.dart';
import '../../selectors/selectors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const validEmail = 'karim@rythmify.com';
  const validPassword = 'Karim123!';
  const invalidPassword = 'WrongPassword1!';

  group('Login', () {
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

  //   testWidgets('login page loads correctly', (tester) async {
  //     app.main();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     final loginPage = LoginPage(tester);
  //     expect(loginPage.isOnLoginPage(), true);
  //     expect(find.byKey(const Key('auth_social_google_button')), findsOneWidget);
  //     expect(find.byKey(const Key('auth_social_apple_button')), findsOneWidget);
  //     expect(find.byKey(const Key('auth_continue_button')), findsOneWidget);
  //   });

  //   testWidgets('empty email shows validation error', (tester) async {
  //     app.main();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     final loginPage = LoginPage(tester);
  //     await loginPage.tapContinue();

  //     expect(find.text('Please enter your email'), findsOneWidget);
  //   });

  //   testWidgets('invalid email shows validation error', (tester) async {
  //     app.main();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     final loginPage = LoginPage(tester);
  //     await loginPage.enterEmail('notanemail');
  //     await loginPage.tapContinue();

  //     expect(find.text('Please enter a valid email'), findsOneWidget);
  //   });

  //   testWidgets('valid email navigates to login password page', (tester) async {
  //     app.main();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     final loginPage = LoginPage(tester);
  //     await loginPage.enterEmail(validEmail);
  //     await loginPage.tapContinue();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     expect(loginPage.isOnPasswordPage(), true);
  //     expect(find.text(validEmail), findsOneWidget);
  //   });

  //   testWidgets('empty password shows validation error', (tester) async {
  //     app.main();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     final loginPage = LoginPage(tester);
  //     await loginPage.enterEmail(validEmail);
  //     await loginPage.tapContinue();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));
  //     await loginPage.tapLogin();

  //     expect(find.text('Please enter your password'), findsOneWidget);
  //   });

  //   testWidgets('invalid password shows authentication error', (tester) async {
  //     app.main();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     final loginPage = LoginPage(tester);
  //     await loginPage.enterEmail(validEmail);
  //     await loginPage.tapContinue();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));
  //     await loginPage.enterPassword(invalidPassword);
  //     await loginPage.tapLogin();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     expect(find.text('Invalid email or password.'), findsOneWidget);
  //     expect(loginPage.isOnPasswordPage(), true);
  //   });

  //   testWidgets('successful email login navigates to home', (tester) async {
  //     app.main();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     final loginPage = LoginPage(tester);
  //     await loginPage.login(validEmail, validPassword);
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     expect(loginPage.isOnHomePage(), true);
  //   });

  //   testWidgets('google login works with mock auth and reaches home', (tester) async {
  //     app.main();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     final loginPage = LoginPage(tester);
  //     await loginPage.tapGoogleSignIn();
  //     await tester.pumpAndSettle(const Duration(seconds: 5));

  //     expect(loginPage.isOnHomePage(), true);
  //   });
  });
}
