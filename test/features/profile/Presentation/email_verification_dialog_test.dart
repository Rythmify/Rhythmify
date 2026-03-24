import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_provider.dart';
import 'package:rythmify/features/authentication/presentation/providers/auth_state.dart';
import 'package:rythmify/features/authentication/presentation/widgets/email_verification_dialog.dart';

class MockAuthNotifier implements AuthNotifier {
  @override
  AuthState build() => const AuthUnauthenticated();

  @override
  Future<void> sendEmailVerification() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('EmailVerificationDialog', () {
    testWidgets('should display title text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: EmailVerificationDialog())),
        ),
      );

      expect(find.text('Verify your email'), findsOneWidget);
    });

    testWidgets('should display description text', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: EmailVerificationDialog())),
        ),
      );

      expect(
        find.text(
          'We sent a verification link to your email. Please check your inbox and verify before continuing.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('should display Resend email button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: EmailVerificationDialog())),
        ),
      );

      expect(find.text('Resend email'), findsOneWidget);
    });

    testWidgets('should display Dismiss button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: EmailVerificationDialog())),
        ),
      );

      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('should close dialog when Dismiss is tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) =>
                        const ProviderScope(child: EmailVerificationDialog()),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Verify your email'), findsOneWidget);

      await tester.tap(
        find.byKey(const Key('authentication_dismiss_text_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify your email'), findsNothing);
    });

    testWidgets('should show email icon', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: EmailVerificationDialog())),
        ),
      );

      expect(find.byIcon(Icons.mark_email_unread_outlined), findsOneWidget);
    });

    testWidgets('should render with correct widget keys', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: EmailVerificationDialog())),
        ),
      );

      expect(
        find.byKey(const Key('authentication_verify_email_title_text')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('authentication_verify_email_description_text')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('authentication_resend_email_elevated_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('authentication_dismiss_text_button')),
        findsOneWidget,
      );
    });
  });
}
