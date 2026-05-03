import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/premium/presentation/providers/premium_provider.dart';
import 'package:rythmify/features/premium/presentation/screens/cancellation_screen.dart';
import 'package:rythmify/features/premium/domain/entities/user_subscription.dart';
import 'package:rythmify/features/premium/domain/entities/subscription_plan.dart';

class MockPremiumNotifier extends PremiumNotifier {
  final PremiumState _state;
  MockPremiumNotifier(this._state);
  @override
  PremiumState build() => _state;
  @override
  Future<void> cancel() async {}
  @override
  Future<void> loadMySubscription() async {}
}

void main() {
  const tPlan = SubscriptionPlan(
    planId: 'plan-123',
    name: 'premium',
    price: '9.99',
    durationDays: 30,
    trackLimit: null,
    playlistLimit: null,
  );

  const tSubscription = UserSubscription(
    subscriptionId: 'sub-456',
    userId: 'user-789',
    status: 'active',
    startDate: '2024-01-01',
    endDate: '2024-02-01',
    autoRenew: true,
    plan: tPlan,
  );

  group('CancellationScreen', () {
    testWidgets('renders active premium status', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumProvider.overrideWith(
              () => MockPremiumNotifier(
                const PremiumState(subscription: tSubscription),
              ),
            ),
            isPremiumProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(home: CancellationScreen()),
        ),
      );

      expect(find.text('★ PREMIUM ACTIVE'), findsOneWidget);
      expect(find.text("You're Premium."), findsOneWidget);
      expect(find.text('Cancel subscription'), findsOneWidget);
    });

    testWidgets('shows timer when canceled', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumProvider.overrideWith(
              () => MockPremiumNotifier(
                const PremiumState(
                  subscription: tSubscription,
                  isInitialized: true,
                ),
              ),
            ),
            isPremiumProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(home: CancellationScreen()),
        ),
      );

      await tester.tap(find.text('Cancel subscription'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel subscription?'), findsOneWidget);
      await tester.tap(find.text('Cancel anyway'));
      await tester.pumpAndSettle();

      expect(find.text('Session ends in'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders free tier status', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            premiumProvider.overrideWith(
              () => MockPremiumNotifier(const PremiumState()),
            ),
            isPremiumProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(home: CancellationScreen()),
        ),
      );

      expect(find.text('FREE TIER'), findsOneWidget);
      expect(find.text("Not Premium."), findsOneWidget);
      expect(
        find.text('Upgrade to Artist Pro to unlock the full experience.'),
        findsOneWidget,
      );
    });
  });
}
