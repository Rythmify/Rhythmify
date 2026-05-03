import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/player/domain/entities/history_record.dart';

void main() {
  group('HistoryRecord', () {
    final tPlayedAt = DateTime(2023, 1, 1);
    test('should support value equality', () {
      expect(
        HistoryRecord(
          trackId: '1',
          playedAt: tPlayedAt,
          durationPlayedSeconds: 100,
        ),
        HistoryRecord(
          trackId: '1',
          playedAt: tPlayedAt,
          durationPlayedSeconds: 100,
        ),
      );
    });

    test('props should contain all fields', () {
      final record = HistoryRecord(
        trackId: '1',
        playedAt: tPlayedAt,
        durationPlayedSeconds: 100,
      );
      expect(record.props, ['1', tPlayedAt, 100]);
    });
  });
}
