import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/profile/presentation/widgets/profile_avatar.dart';

void main() {
  group('ProfileAvatar', () {
    testWidgets('should show person icon when avatarUrl is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(avatarUrl: null),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets(
        'should NOT show camera icon by default',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(avatarUrl: null),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt), findsNothing);
    });

    testWidgets(
        'should show camera icon when showCameraIcon is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              avatarUrl: null,
              showCameraIcon: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              avatarUrl: null,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('profile_avatar_gesture')));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should use provided radius', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(
              avatarUrl: null,
              radius: 40,
            ),
          ),
        ),
      );

      final avatar =
          tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 40);
    });

    testWidgets('should render with gesture key', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(avatarUrl: null),
          ),
        ),
      );

      expect(find.byKey(const Key('profile_avatar_gesture')),
          findsOneWidget);
    });
  });
}
