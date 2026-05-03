import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/premium/presentation/widgets/premium_upgrade_prompt.dart';

void main() {
  group('PremiumUpgradePrompt', () {
    testWidgets('shows modal bottom sheet with correct reason', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    PremiumUpgradePrompt.show(
                      context,
                      reason: 'upload more tracks',
                    );
                  },
                  child: const Text('Show Prompt'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Prompt'));
      await tester.pumpAndSettle();

      expect(find.text('Upgrade to Premium'), findsOneWidget);
      expect(
        find.textContaining('Upgrade to Premium to upload more tracks'),
        findsOneWidget,
      );
      expect(find.text('See Premium plans'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('dismisses when Not now is tapped', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    PremiumUpgradePrompt.show(context, reason: 'test reason');
                  },
                  child: const Text('Show Prompt'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Prompt'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(find.text('Upgrade to Premium'), findsNothing);
    });
  });
}
