import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/feed/presentation/widgets/feed_tab_bar.dart';

void main() {
  group('FeedTabBar Widget', () {
    late TabController tTabController;

    setUp(() {
      tTabController = TabController(length: 2, vsync: TestVSync());
    });

    tearDown(() {
      tTabController.dispose();
    });

    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      expect(find.byType(FeedTabBar), findsOneWidget);
    });

    testWidgets('displays SizedBox with correct dimensions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      final sizedBox = find.byKey(const Key('feed_tab_bar_sizedbox'));
      expect(sizedBox, findsOneWidget);

      final sizedBoxWidget = tester.widget<SizedBox>(sizedBox);
      expect(sizedBoxWidget.width, equals(250));
      expect(sizedBoxWidget.height, equals(45));
    });

    testWidgets('displays TabBar with correct key', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      expect(find.byKey(const Key('feed_tab_bar')), findsOneWidget);
    });

    testWidgets('displays Discover and Following tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
    });

    testWidgets('tabs have correct keys', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      expect(find.byKey(const Key('feed_tab_discover')), findsOneWidget);
      expect(find.byKey(const Key('feed_tab_following')), findsOneWidget);
    });

    testWidgets('tab indicator changes when controller index changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      expect(tTabController.index, equals(0));

      tTabController.index = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      expect(tTabController.index, equals(1));
    });

    testWidgets('displays correct indicator styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.indicatorSize, equals(TabBarIndicatorSize.tab));
      expect(tabBar.dividerColor, equals(Colors.transparent));
    });

    testWidgets('tab label colors are correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.labelColor, equals(Colors.white));
      expect(tabBar.unselectedLabelColor, equals(Colors.white60));
    });

    testWidgets('tab label style has correct properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.labelStyle?.fontWeight, equals(FontWeight.bold));
      expect(tabBar.labelStyle?.fontSize, equals(15));
    });

    testWidgets('indicator has correct border radius', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      final indicator = tabBar.indicator as BoxDecoration;
      expect(indicator.borderRadius, isNotNull);
    });

    testWidgets('responds to tab controller', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: FeedTabBar(controller: tTabController)),
        ),
      );

      // Tap on Following tab
      await tester.tap(find.byKey(const Key('feed_tab_following')));
      await tester.pumpAndSettle();

      expect(tTabController.index, equals(1));
    });

    testWidgets('maintains state across rebuilds', (WidgetTester tester) async {
      final key = UniqueKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedTabBar(key: key, controller: tTabController),
          ),
        ),
      );

      tTabController.index = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedTabBar(key: key, controller: tTabController),
          ),
        ),
      );

      expect(tTabController.index, equals(1));
    });
  });
}
