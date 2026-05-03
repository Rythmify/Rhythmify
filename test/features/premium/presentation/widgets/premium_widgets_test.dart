import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/premium/presentation/widgets/premium_widgets.dart';
import 'package:rythmify/features/premium/presentation/widgets/premium_hero_widgets.dart';

void main() {
  group('PremiumTag', () {
    testWidgets('renders correct label and colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumTag(
              label: 'TEST TAG',
              bg: Colors.red,
              textColor: Colors.white,
            ),
          ),
        ),
      );

      expect(find.text('TEST TAG'), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container));
      expect((container.decoration as BoxDecoration).color, Colors.red);
    });
  });

  group('BlueLink', () {
    testWidgets('renders label and handles tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlueLink(
              label: 'Link Label',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Link Label'), findsOneWidget);
      await tester.tap(find.text('Link Label'));
      expect(tapped, isTrue);
    });
  });

  group('PlanCard', () {
    testWidgets('renders all components and handles subscribe', (tester) async {
      bool subscribed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlanCard(
              periodLabel: 'MONTHLY',
              periodColor: Colors.blue,
              planName: 'Premium Plan',
              priceDisplay: '\$9.99',
              features: const ['Feature 1', 'Feature 2'],
              onSubscribe: () => subscribed = true,
            ),
          ),
        ),
      );

      expect(find.text('MONTHLY'), findsOneWidget);
      expect(find.text('Premium Plan'), findsOneWidget);
      expect(find.text('\$9.99'), findsOneWidget);
      expect(find.text('Feature 1'), findsOneWidget);
      expect(find.text('Feature 2'), findsOneWidget);
      expect(find.text('Subscribe now'), findsOneWidget);

      await tester.tap(find.text('Subscribe now'));
      expect(subscribed, isTrue);
    });
  });

  group('Sheets', () {
    testWidgets('showRestrictionsSheet renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => showRestrictionsSheet(context),
                  child: const Text('Open Sheet'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Restrictions apply'), findsOneWidget);
      expect(find.text('Terms of Use'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('showTextDocSheet renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => showTextDocSheet(context, 'Title', 'Body Text'),
                  child: const Text('Open Doc'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Doc'));
      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Body Text'), findsOneWidget);
    });
  });

  group('PremiumDarkInfoSection', () {
    testWidgets('renders and handles FAQ expansion', (tester) async {
      tester.view.physicalSize = const Size(800, 1500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumDarkInfoSection(bottomPad: 0),
          ),
        ),
      );

      expect(find.text('Rythmify supports\nindependent artists'), findsOneWidget);
      expect(find.text('Frequently asked questions'), findsOneWidget);

      // Tap first FAQ
      final faqText = "What's the difference between fan and artist plans?";
      expect(find.text(faqText), findsOneWidget);
      
      // Answer should be hidden initially
      expect(find.textContaining('Our fan-oriented plans are designed'), findsNothing);

      await tester.tap(find.text(faqText));
      await tester.pumpAndSettle();

      // Answer should be visible
      expect(find.textContaining('Our fan-oriented plans are designed'), findsOneWidget);
    });
  });

  group('HeroSection', () {
    testWidgets('renders UpsellContent when not premium', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroSection(
              isPremium: false,
              endDate: null,
              onContinue: () {},
              onSeeAllPlans: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Unlock unlimited\nuploads &\nmore.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('renders ActivePremiumInfo when premium', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroSection(
              isPremium: true,
              endDate: '2024-12-31',
              onContinue: () {},
              onSeeAllPlans: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text("You're Premium!"), findsOneWidget);
      expect(find.text('Active until 2024-12-31'), findsOneWidget);
      expect(find.text('Cancel subscription'), findsOneWidget);
    });
  });
}
