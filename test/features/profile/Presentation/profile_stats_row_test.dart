import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/profile/presentation/widgets/profile_stats_row.dart';

void main() {
  group('ProfileStatsRow', () {
    testWidgets('should display followers count correctly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatsRow(
              followersCount: 500,
              followingCount: 100,
            ),
          ),
        ),
      );

      expect(find.text('500 Followers'), findsOneWidget);
    });

    testWidgets('should display following count correctly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatsRow(
              followersCount: 500,
              followingCount: 100,
            ),
          ),
        ),
      );

      expect(find.text('100 Following'), findsOneWidget);
    });

    testWidgets('should format thousands with K suffix',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatsRow(
              followersCount: 1240,
              followingCount: 380,
            ),
          ),
        ),
      );

      expect(find.text('1.2K Followers'), findsOneWidget);
      expect(find.text('380 Following'), findsOneWidget);
    });

    testWidgets('should format millions with M suffix',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatsRow(
              followersCount: 1500000,
              followingCount: 200,
            ),
          ),
        ),
      );

      expect(find.text('1.5M Followers'), findsOneWidget);
    });

    testWidgets('should display zero counts correctly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatsRow(
              followersCount: 0,
              followingCount: 0,
            ),
          ),
        ),
      );

      expect(find.text('0 Followers'), findsOneWidget);
      expect(find.text('0 Following'), findsOneWidget);
    });

    testWidgets('should show separator dot between counts',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatsRow(
              followersCount: 100,
              followingCount: 50,
            ),
          ),
        ),
      );

      expect(find.text('·'), findsOneWidget);
    });

    testWidgets('should render with correct widget keys',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileStatsRow(
              followersCount: 100,
              followingCount: 50,
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('profile_stats_followers_text')),
          findsOneWidget);
      expect(find.byKey(const Key('profile_stats_following_text')),
          findsOneWidget);
    });
  });
}
