import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rythmify/features/premium/presentation/screens/upgrade_landing_screen.dart';

void main() {
  testWidgets(
    'Premium subscription flow - landing screen shows Continue button',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: UpgradeLandingScreen()));

      await tester.pumpAndSettle();

      // Core subscription entry point
      expect(find.text('Continue'), findsOneWidget);

      // Key premium message
      expect(find.textContaining('Unlock artist tools'), findsOneWidget);
    },
  );

  testWidgets('Premium subscription flow - See all plans is available', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: UpgradeLandingScreen()));

    expect(find.text('See all plans'), findsOneWidget);
  });
}
