import '../repositories/playback_repository.dart';

class SyncHistoryUseCase {
  final PlaybackRepository _repository;

  SyncHistoryUseCase(this._repository);

  Future<void> call() {
    return _repository.syncPendingHistory();
  }
}
