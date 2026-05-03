import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rythmify/features/premium/presentation/providers/premium_provider.dart';
import 'package:rythmify/features/premium/presentation/screens/checkout_screen.dart';

class MockPremiumNotifier extends PremiumNotifier {
  final PremiumState _initialState;
  MockPremiumNotifier(this._initialState);
  @override
  PremiumState build() => _initialState;

  set state(PremiumState newState) => super.state = newState;

  @override
  Future<void> checkout(String planId) async {}
  @override
  void clearCheckoutSuccess() {}
  @override
  void clearError() {}
}

void main() {
  group('CheckoutScreen', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: '/checkout',
        routes: [
          GoRoute(
            path: '/checkout',
            builder: (context, state) => const CheckoutScreen(
              planId: 'plan-123',
              planName: 'Artist Pro',
              price: 'EGP 164.99',
              features: ['Feature 1'],
            ),
          ),
          GoRoute(
            path: '/upgrade/plans',
            builder: (_, __) => const Scaffold(body: Text('plans')),
          ),
          GoRoute(
            path: '/upgrade',
            builder: (_, __) => const Scaffold(body: Text('upgrade')),
          ),
        ],
      );
    });

    testWidgets('renders plan details and handles payment', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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

      expect(find.text('Artist Pro'), findsOneWidget);
      expect(find.text('EGP 164.99'), findsOneWidget);
      expect(find.text('Feature 1'), findsOneWidget);
      expect(find.text('Confirm Payment'), findsOneWidget);

      await tester.tap(find.text('Confirm Payment'));
      await tester.pump();
    });

    testWidgets('shows success sheet when checkoutSuccess is true', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final notifier = MockPremiumNotifier(const PremiumState());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [premiumProvider.overrideWith(() => notifier)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger success state
      notifier.state = const PremiumState(checkoutSuccess: true);
      await tester.pumpAndSettle();

      expect(find.text("You're now Premium!"), findsOneWidget);
      expect(find.text('Start exploring'), findsOneWidget);
    });

    testWidgets('back button handles navigation', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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

      final backButton = find.byIcon(Icons.arrow_back_ios_new);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('plans'), findsOneWidget);
    });

    testWidgets('shows loading state when isCheckingOut is true', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumProvider.overrideWith(
              () =>
                  MockPremiumNotifier(const PremiumState(isCheckingOut: true)),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Confirm Payment'), findsNothing);
    });

    testWidgets('shows error message when state has error', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumProvider.overrideWith(
              () => MockPremiumNotifier(
                const PremiumState(error: 'Payment failed'),
              ),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Payment failed. Please try again.'), findsOneWidget);
    });
  });
}
