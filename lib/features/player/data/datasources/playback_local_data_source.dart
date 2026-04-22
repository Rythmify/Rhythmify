import 'package:hive/hive.dart';
import '../models/history_record_model.dart';

abstract class PlaybackLocalDataSource {
  Future<void> cacheHistoryRecord(HistoryRecordModel record);
  Future<List<HistoryRecordModel>> getPendingHistoryRecords();
  Future<void> removeHistoryRecords(List<HistoryRecordModel> records);
}

class PlaybackLocalDataSourceImpl implements PlaybackLocalDataSource {
  static const String _boxName = 'pending_history_v1';

  Future<Box> _openBox() async {
    return await Hive.openBox(_boxName);
  }

  @override
  Future<void> cacheHistoryRecord(HistoryRecordModel record) async {
    final box = await _openBox();
    // Using a timestamp-based key to ensure uniqueness
    final key = '${record.trackId}_${record.playedAt.millisecondsSinceEpoch}';
    await box.put(key, record.toJson());
  }

  @override
  Future<List<HistoryRecordModel>> getPendingHistoryRecords() async {
    final box = await _openBox();
    return box.values
        .map(
          (e) =>
              HistoryRecordModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  @override
  Future<void> removeHistoryRecords(List<HistoryRecordModel> records) async {
    final box = await _openBox();
    for (final record in records) {
      final key = '${record.trackId}_${record.playedAt.millisecondsSinceEpoch}';
      await box.delete(key);
    }
  }
}
