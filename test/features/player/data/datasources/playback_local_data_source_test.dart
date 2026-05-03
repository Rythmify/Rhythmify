import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rythmify/features/player/data/datasources/playback_local_data_source.dart';
import 'package:rythmify/features/player/data/models/history_record_model.dart';
import '../data_test_helper.dart';

void main() {
  setUpAll(() {
    registerTestFallbacks();
  });

  late PlaybackLocalDataSourceImpl dataSource;
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
    dataSource = PlaybackLocalDataSourceImpl(box: mockBox);
  });

  final tHistoryRecordModel = HistoryRecordModel(
    trackId: '1',
    playedAt: DateTime.parse('2023-01-01T00:00:00.000'),
    durationPlayedSeconds: 120,
  );

  final tKey = '1_${tHistoryRecordModel.playedAt.millisecondsSinceEpoch}';

  group('cacheHistoryRecord', () {
    test('should call box.put with correct key and data', () async {
      // arrange
      when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

      // act
      await dataSource.cacheHistoryRecord(tHistoryRecordModel);

      // assert
      verify(() => mockBox.put(tKey, tHistoryRecordModel.toJson())).called(1);
    });
  });

  group('getPendingHistoryRecords', () {
    test('should return list of history records from box', () async {
      // arrange
      final tJson = tHistoryRecordModel.toJson();
      when(() => mockBox.values).thenReturn([tJson]);

      // act
      final result = await dataSource.getPendingHistoryRecords();

      // assert
      expect(result, [tHistoryRecordModel]);
      verify(() => mockBox.values).called(1);
    });
  });

  group('removeHistoryRecords', () {
    test('should call box.delete for each record', () async {
      // arrange
      when(() => mockBox.delete(any())).thenAnswer((_) async => {});

      // act
      await dataSource.removeHistoryRecords([tHistoryRecordModel]);

      // assert
      verify(() => mockBox.delete(tKey)).called(1);
    });
  });
}
