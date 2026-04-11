import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/comments/presentation/widgets/floating_comment.dart';

void main() {
  Widget buildWidgetUnderTest({String? imageUrl, required String text}) {
    return MaterialApp(
      home: Scaffold(
        body: FloatingComment(
          imageUrl: imageUrl,
          text: text,
        ),
      ),
    );
  }

  group('FloatingComment', () {
    testWidgets('renders text correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidgetUnderTest(text: 'Great drop!'));

      expect(find.text('Great drop!'), findsOneWidget);
    });

    testWidgets('renders default icon when imageUrl is null', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidgetUnderTest(text: 'No image', imageUrl: null));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders default icon when imageUrl is empty', (WidgetTester tester) async {
      await tester.pumpWidget(buildWidgetUnderTest(text: 'Empty image', imageUrl: ''));

      expect(find.byIcon(Icons.person), findsOneWidget);
    });
    
    testWidgets('has correct structure when imageUrl is provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildWidgetUnderTest(
          text: 'Has image',
          imageUrl: 'https://example.com/pfp.jpg',
        ),
      );

      final containerFinder = find.byType(Container).first;
      final Container container = tester.widget(containerFinder);
      final BoxDecoration decoration = container.decoration as BoxDecoration;

      expect(decoration.image, isNotNull);
      expect(decoration.image?.image, isA<NetworkImage>());
    });
  });
}
