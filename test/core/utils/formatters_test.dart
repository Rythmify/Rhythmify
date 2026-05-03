import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('formatDuration formats correctly', () {
      expect(Formatters.formatDuration(const Duration(minutes: 1, seconds: 5)), '01:05');
      expect(Formatters.formatDuration(const Duration(seconds: 120)), '02:00');
    });

    test('formatCount formats correctly', () {
      expect(Formatters.formatCount(100), '100');
      expect(Formatters.formatCount(1500), '1.5K');
      expect(Formatters.formatCount(1200000), '1.2M');
    });
  });
}
