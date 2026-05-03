import 'package:flutter_test/flutter_test.dart';
import 'package:rythmify/features/player/data/models/history_record_model.dart';
import 'package:rythmify/features/player/domain/entities/history_record.dart';

void main() {
  final tHistoryRecordModel = HistoryRecordModel(
    trackId: '1',
    playedAt: DateTime.parse('2023-01-01T00:00:00.000'),
    durationPlayedSeconds: 120,
  );

  final tHistoryRecord = HistoryRecord(
    trackId: '1',
    playedAt: DateTime.parse('2023-01-01T00:00:00.000'),
    durationPlayedSeconds: 120,
  );

  group('HistoryRecordModel', () {
    test('should be a subclass of HistoryRecord entity', () {
      expect(tHistoryRecordModel, isA<HistoryRecord>());
    });

    test('fromEntity should return a valid model', () {
      final result = HistoryRecordModel.fromEntity(tHistoryRecord);
      expect(result, tHistoryRecordModel);
    });

    test('fromJson should return a valid model', () {
      final Map<String, dynamic> jsonMap = {
        'track_id': '1',
        'played_at': '2023-01-01T00:00:00.000',
        'duration_played_seconds': 120,
      };
      final result = HistoryRecordModel.fromJson(jsonMap);
      expect(result, tHistoryRecordModel);
    });

    test('toJson should return a JSON map containing the proper data', () {
      final result = tHistoryRecordModel.toJson();
      final expectedMap = {
        'track_id': '1',
        'played_at': '2023-01-01T00:00:00.000',
        'duration_played_seconds': 120,
      };
      expect(result, expectedMap);
    });
  });
}
