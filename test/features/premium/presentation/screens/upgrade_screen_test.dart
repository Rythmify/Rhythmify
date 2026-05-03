import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/premium/presentation/providers/premium_provider.dart';
import 'package:rythmify/features/premium/presentation/screens/upgrade_screen.dart';

class MockPremiumNotifier extends PremiumNotifier {
  final PremiumState _state;
  MockPremiumNotifier(this._state);
  @override
  PremiumState build() => _state;
}

void main() {
  group('UpgradeScreen', () {
    testWidgets('renders plans and FAQ', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumProvider.overrideWith(
              () => MockPremiumNotifier(const PremiumState()),
            ),
          ],
          child: const MaterialApp(home: UpgradeScreen()),
        ),
      );

      expect(
        find.text("What's next in music is first\non Rythmify"),
        findsOneWidget,
      );
      expect(find.text('Artist Pro ★'), findsAtLeast(1));
      expect(find.text('Subscribe now'), findsAtLeast(1));
      expect(find.text('Frequently asked questions'), findsOneWidget);
    });

    testWidgets('can swipe through plans', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumProvider.overrideWith(
              () => MockPremiumNotifier(const PremiumState()),
            ),
          ],
          child: const MaterialApp(home: UpgradeScreen()),
        ),
      );

      // Initial plan
      expect(find.text('EGP 164.99/month'), findsOneWidget);

      // Swipe to next plan (Yearly Pro)
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('EGP 1,149.99/year'), findsOneWidget);
    });
  });
}
