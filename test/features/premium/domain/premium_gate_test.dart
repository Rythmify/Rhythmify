import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/premium/domain/premium_gate.dart';

void main() {
  group('PremiumGate', () {
    testWidgets(
      'handleError returns true and shows bottom sheet for 403 SUBSCRIPTION_LIMIT_REACHED',
      (tester) async {
        final dioError = DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 403,
            data: {
              'error': {'code': 'SUBSCRIPTION_LIMIT_REACHED'},
            },
          ),
        );

        bool? result;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      result = PremiumGate.handleError(context, dioError);
                    },
                    child: const Text('Tap'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Tap'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
        expect(find.text('Upgrade to Premium'), findsOneWidget);
      },
    );

    testWidgets('handleError returns false for other errors', (tester) async {
      final otherError = Exception('Some other error');

      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    result = PremiumGate.handleError(context, otherError);
                  },
                  child: const Text('Tap'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(find.text('Upgrade to Premium'), findsNothing);
    });

    testWidgets('handleError returns true if error string contains code', (
      tester,
    ) async {
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    result = PremiumGate.handleError(
                      context,
                      'Error: SUBSCRIPTION_LIMIT_REACHED',
                    );
                  },
                  child: const Text('Tap'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('Upgrade to Premium'), findsOneWidget);
    });
  });
}
