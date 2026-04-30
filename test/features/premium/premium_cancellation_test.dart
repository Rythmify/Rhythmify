import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Cancellation flow - Manage subscription button exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextButton(
            onPressed: () {},
            child: const Text('Manage subscription'),
          ),
        ),
      ),
    );

    expect(find.text('Manage subscription'), findsOneWidget);
  });

  testWidgets('Cancellation flow - Not now option exists in modal', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextButton(onPressed: () {}, child: const Text('Not now')),
        ),
      ),
    );

    expect(find.text('Not now'), findsOneWidget);
  });
}
