import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/profile/presentation/widgets/unsaved_changes_dialog.dart';

void main() {
  group('UnsavedChangesDialog', () {
    testWidgets('should display title and description text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UnsavedChangesDialog())),
      );

      expect(find.text('Are you sure?'), findsOneWidget);
      expect(
        find.text('You have unsaved changes that will be lost'),
        findsOneWidget,
      );
    });

    testWidgets('should display Discard Changes button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UnsavedChangesDialog())),
      );

      expect(find.text('DISCARD CHANGES'), findsOneWidget);
    });

    testWidgets('should display Continue Editing button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UnsavedChangesDialog())),
      );

      expect(find.text('CONTINUE EDITING'), findsOneWidget);
    });

    testWidgets('should return true when Discard Changes is tapped', (
      tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<bool>(
                    context: context,
                    builder: (_) => const UnsavedChangesDialog(),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('profile_unsaved_changes_discard_button')),
      );
      await tester.pumpAndSettle();

      expect(result, true);
    });

    testWidgets('should return false when Continue Editing is tapped', (
      tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showDialog<bool>(
                    context: context,
                    builder: (_) => const UnsavedChangesDialog(),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('profile_unsaved_changes_continue_button')),
      );
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('should render with correct widget keys', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: UnsavedChangesDialog())),
      );

      expect(
        find.byKey(const Key('profile_unsaved_changes_title_text')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('profile_unsaved_changes_description_text')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('profile_unsaved_changes_discard_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('profile_unsaved_changes_continue_button')),
        findsOneWidget,
      );
    });
  });
}
