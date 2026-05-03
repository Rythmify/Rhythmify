import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/premium/presentation/providers/premium_provider.dart';
import 'package:rythmify/features/premium/presentation/screens/upgrade_landing_screen.dart';

class MockPremiumNotifier extends PremiumNotifier {
  final PremiumState _state;
  MockPremiumNotifier(this._state);
  @override
  PremiumState build() => _state;
}

void main() {
  group('UpgradeLandingScreen', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: '/upgrade-landing',
        routes: [
          GoRoute(
            path: '/upgrade-landing',
            builder: (context, state) => const UpgradeLandingScreen(),
          ),
          GoRoute(
            path: '/upgrade/checkout',
            builder: (_, __) => const Scaffold(body: Text('checkout')),
          ),
          GoRoute(
            path: '/upgrade/plans',
            builder: (_, __) => const Scaffold(body: Text('plans')),
          ),
        ],
      );
    });

    testWidgets('renders all components', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumProvider.overrideWith(
              () => MockPremiumNotifier(const PremiumState()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Unlock artist tools\n& unlimited\nuploads.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('See all plans'), findsOneWidget);
    });

    testWidgets('shows restrictions sheet on tap', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumProvider.overrideWith(
              () => MockPremiumNotifier(const PremiumState()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Restrictions apply.'));
      await tester.pumpAndSettle();

      expect(find.text('Restrictions apply'), findsOneWidget);
    });

    testWidgets('can tap Continue', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumProvider.overrideWith(
              () => MockPremiumNotifier(const PremiumState()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      
      expect(find.text('checkout'), findsOneWidget);
    });

    testWidgets('can tap See all plans', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumProvider.overrideWith(
              () => MockPremiumNotifier(const PremiumState()),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('See all plans'));
      await tester.pumpAndSettle();
      
      expect(find.text('plans'), findsOneWidget);
    });
  });
}
