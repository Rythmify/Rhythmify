import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/authentication/presentation/pages/onboarding_page.dart';

void main() {
  group('OnboardingPage', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: '/onboarding',
        routes: [
          GoRoute(
            path: '/onboarding',
            builder: (_, __) => const OnboardingPage(),
          ),
          GoRoute(
            path: '/sign-in',
            builder: (_, state) => Scaffold(
              body: Text('sign-in-${state.extra}'),
            ),
          ),
        ],
      );
    });

    testWidgets('should display Create an account button',
        (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Create an account'), findsOneWidget);
    });

    testWidgets('should display Log in button', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Log in'), findsOneWidget);
    });

    testWidgets(
        'should navigate to sign-in with register mode when Create account is tapped',
        (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create an account'));
      await tester.pumpAndSettle();

      expect(find.text('sign-in-register'), findsOneWidget);
    });

    testWidgets(
        'should navigate to sign-in with login mode when Log in is tapped',
        (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('sign-in-login'), findsOneWidget);
    });

    testWidgets('should display tagline text', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('Where artists & fans connect.'), findsOneWidget);
    });
  });
}
