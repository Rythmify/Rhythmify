import 'package:flutter/foundation.dart';
import '../../domain/entities/history_record.dart';
import '../../domain/repositories/playback_repository.dart';
import '../datasources/playback_local_data_source.dart';
import '../datasources/playback_remote_data_source.dart';
import '../models/history_record_model.dart';

class PlaybackRepositoryImpl implements PlaybackRepository {
  final PlaybackRemoteDataSource _remoteDataSource;
  final PlaybackLocalDataSource _localDataSource;

  PlaybackRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<String> initiatePlayback(String trackId) async {
    try {
      return await _remoteDataSource.initiatePlayback(trackId);
    } catch (e) {
      debugPrint('[PlaybackRepository] Error initiating playback: $e');
      rethrow;
    }
  }

  @override
  Future<void> recordListeningHistory(HistoryRecord record) async {
    final model = HistoryRecordModel.fromEntity(record);
    try {
      await _remoteDataSource.recordHistory(model);
    } catch (e) {
      debugPrint(
        '[PlaybackRepository] Error recording history, caching locally: $e',
      );
      await _localDataSource.cacheHistoryRecord(model);
    }
  }

  @override
  Future<void> syncPendingHistory() async {
    final pending = await _localDataSource.getPendingHistoryRecords();
    if (pending.isEmpty) return;

    final successfullySynced = <HistoryRecordModel>[];

    for (final record in pending) {
      try {
        await _remoteDataSource.recordHistory(record);
        successfullySynced.add(record);
      } catch (e) {
        debugPrint(
          '[PlaybackRepository] Sync failed for record ${record.trackId}: $e',
        );
        // Stop sync on first error to avoid spamming the backend if it's down
        break;
      }
    }

    if (successfullySynced.isNotEmpty) {
      await _localDataSource.removeHistoryRecords(successfullySynced);
      debugPrint(
        '[PlaybackRepository] Synced ${successfullySynced.length} records',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> fetchQueueContext({
    required String interactionType,
    required String sourceType,
    String? sourceId,
    String? targetUserId,
  }) async {
    return await _remoteDataSource.fetchQueueContext(
      interactionType: interactionType,
      sourceType: sourceType,
      sourceId: sourceId,
      targetUserId: targetUserId,
    );
  }

  @override
  Future<void> syncPlayerState({
    required String trackId,
    required List<Map<String, dynamic>> queue,
    int positionSeconds = 0,
    double volume = 0.5,
  }) async {
    await _remoteDataSource.syncPlayerState(
      trackId: trackId,
      queue: queue,
      positionSeconds: positionSeconds,
      volume: volume,
    );
  }
}
