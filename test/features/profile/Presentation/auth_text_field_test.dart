import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/authentication/presentation/widgets/auth_text_field.dart';

void main() {
  group('AuthTextField', () {
    testWidgets(
        'should render hint text when controller is empty',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              hint: 'Your email address',
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Your email address'), findsOneWidget);
    });

    testWidgets(
        'should display entered text',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              hint: 'Your email address',
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'test@test.com');
      expect(find.text('test@test.com'), findsOneWidget);
    });

    testWidgets(
        'should show visibility toggle icon when isPassword is true',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              hint: 'Password',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );

      expect(
          find.byKey(
              const Key('auth_password_visibility_icon_button')),
          findsOneWidget);
    });

    testWidgets(
        'should NOT show visibility toggle icon when isPassword is false',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              hint: 'Email',
              controller: controller,
              isPassword: false,
            ),
          ),
        ),
      );

      expect(
          find.byKey(
              const Key('auth_password_visibility_icon_button')),
          findsNothing);
    });

    testWidgets(
        'should toggle password visibility when icon is tapped',
        (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AuthTextField(
              hint: 'Password',
              controller: controller,
              isPassword: true,
            ),
          ),
        ),
      );

      // Initially obscured — visibility_off icon shown
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap to toggle
      await tester.tap(
          find.byKey(const Key('auth_password_visibility_icon_button')));
      await tester.pump();

      // Now visible — visibility icon shown
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets(
        'should call validator and show error message when invalid',
        (tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AuthTextField(
                hint: 'Email',
                controller: controller,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
            ),
          ),
        ),
      );

      formKey.currentState?.validate();
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets(
        'should not show error when validator returns null',
        (tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AuthTextField(
                hint: 'Email',
                controller: controller,
                validator: (_) => null,
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'valid@email.com');
      formKey.currentState?.validate();
      await tester.pump();

      expect(find.text('Required'), findsNothing);
    });
  });
}
