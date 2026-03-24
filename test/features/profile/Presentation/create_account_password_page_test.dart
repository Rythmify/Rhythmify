import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/authentication/presentation/pages/create_account_password_page.dart';

void main() {
  group('CreateAccountPasswordPage', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: '/create-account/password',
        routes: [
          GoRoute(
            path: '/create-account/password',
            builder: (_, __) => const ProviderScope(
              child: CreateAccountPasswordPage(email: 'test@test.com'),
            ),
          ),
          GoRoute(
            path: '/create-account/profile',
            builder: (_, state) {
              final data = state.extra as Map<String, dynamic>;
              return Scaffold(
                body: Text('profile-${data['email']}-${data['password']}'),
              );
            },
          ),
        ],
      );
    });

    testWidgets('should display the email passed as parameter', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.text('test@test.com'), findsOneWidget);
    });

    testWidgets('should display password field', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('authentication_password_text_field')),
        findsOneWidget,
      );
    });

    testWidgets(
      'should show error when password is empty and Continue is tapped',
      (tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const Key('authentication_continue_elevated_button')),
        );
        await tester.pump();

        expect(find.text('Please enter a password'), findsOneWidget);
      },
    );

    testWidgets('should show error when password is less than 8 characters', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('authentication_password_text_field')),
        'Ab1',
      );
      await tester.tap(
        find.byKey(const Key('authentication_continue_elevated_button')),
      );
      await tester.pump();

      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should show error when password has no uppercase letter', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('authentication_password_text_field')),
        'password1',
      );
      await tester.tap(
        find.byKey(const Key('authentication_continue_elevated_button')),
      );
      await tester.pump();

      expect(
        find.text('Password must contain an uppercase letter'),
        findsOneWidget,
      );
    });

    testWidgets('should show error when password has no lowercase letter', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('authentication_password_text_field')),
        'PASSWORD1',
      );
      await tester.tap(
        find.byKey(const Key('authentication_continue_elevated_button')),
      );
      await tester.pump();

      expect(
        find.text('Password must contain a lowercase letter'),
        findsOneWidget,
      );
    });

    testWidgets('should show error when password has no number', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('authentication_password_text_field')),
        'Password',
      );
      await tester.tap(
        find.byKey(const Key('authentication_continue_elevated_button')),
      );
      await tester.pump();

      expect(find.text('Password must contain a number'), findsOneWidget);
    });

    testWidgets(
      'should navigate to profile page when valid password is entered',
      (tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('authentication_password_text_field')),
          'SecurePass1',
        );
        await tester.tap(
          find.byKey(const Key('authentication_continue_elevated_button')),
        );
        await tester.pumpAndSettle();

        expect(find.text('profile-test@test.com-SecurePass1'), findsOneWidget);
      },
    );
  });
}
