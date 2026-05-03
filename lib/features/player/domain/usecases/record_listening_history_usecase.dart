import '../entities/history_record.dart';
import '../repositories/playback_repository.dart';

class RecordListeningHistoryUseCase {
  final PlaybackRepository _repository;

  RecordListeningHistoryUseCase(this._repository);

  Future<void> call(HistoryRecord record) {
    if (record.durationPlayedSeconds <= 0) return Future.value();
    return _repository.recordListeningHistory(record);
  }
}
