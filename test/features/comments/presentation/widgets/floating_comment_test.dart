import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/comments/presentation/widgets/floating_comment.dart';

class MockHttpClient extends Mock implements HttpClient {}
class MockHttpClientRequest extends Mock implements HttpClientRequest {}
class MockHttpClientResponse extends Mock implements HttpClientResponse {}
class MockHttpHeaders extends Mock implements HttpHeaders {}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return createMockHttpClient(context);
  }
}

MockHttpClient createMockHttpClient(SecurityContext? context) {
  final client = MockHttpClient();
  final request = MockHttpClientRequest();
  final response = MockHttpClientResponse();
  final headers = MockHttpHeaders();

  // 1x1 transparent PNG
  final bytes = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
    0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
    0x42, 0x60, 0x82
  ];

  when(() => client.getUrl(any())).thenAnswer((_) async => request);
  when(() => request.headers).thenReturn(headers);
  when(() => request.close()).thenAnswer((_) async => response);
  when(() => response.statusCode).thenReturn(200);
  when(() => response.contentLength).thenReturn(bytes.length);
  when(() => response.compressionState).thenReturn(HttpClientResponseCompressionState.notCompressed);
  when(() => response.listen(any(),
      onDone: any(named: 'onDone'),
      onError: any(named: 'onError'),
      cancelOnError: any(named: 'cancelOnError'))).thenAnswer((invocation) {
    final onData = invocation.positionalArguments[0] as void Function(List<int>);
    final onDone = invocation.namedArguments[#onDone] as void Function()?;
    onData(bytes);
    onDone?.call();
    return MockStreamSubscription<List<int>>();
  });

  return client;
}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {
  @override
  Future<void> cancel() async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
    HttpOverrides.global = TestHttpOverrides();
  });

  group('FloatingComment', () {
    testWidgets('renders content correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingComment(
              text: 'Test Comment',
              imageUrl: null,
            ),
          ),
        ),
      );

      expect(find.text('Test Comment'), findsOneWidget);
    });

    testWidgets('has correct structure when imageUrl is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingComment(
              text: 'Test with Image',
              imageUrl: 'https://example.com/pfp.jpg',
            ),
          ),
        ),
      );

      expect(find.text('Test with Image'), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
      expect((container.decoration as BoxDecoration).shape, BoxShape.circle);
    });
  });
}
