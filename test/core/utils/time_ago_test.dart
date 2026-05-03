import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/core/utils/time_ago.dart';

void main() {
  group('timeAgo', () {
    test('returns "just now" for seconds less than 60', () {
      final now = DateTime.now();
      expect(timeAgo(now.subtract(const Duration(seconds: 30))), 'just now');
    });

    test('returns "Xm ago" for minutes', () {
      final now = DateTime.now();
      expect(timeAgo(now.subtract(const Duration(minutes: 5))), '5m ago');
    });

    test('returns "Xh ago" for hours', () {
      final now = DateTime.now();
      expect(timeAgo(now.subtract(const Duration(hours: 3))), '3h ago');
    });

    test('returns "yesterday" for 1 day', () {
      final now = DateTime.now();
      expect(timeAgo(now.subtract(const Duration(days: 1))), 'yesterday');
    });
  });
}
