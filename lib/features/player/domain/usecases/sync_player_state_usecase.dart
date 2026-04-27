import '../repositories/playback_repository.dart';

class SyncPlayerStateUseCase {
  final PlaybackRepository repository;

  SyncPlayerStateUseCase(this.repository);

  Future<void> call({
    required String trackId,
    required List<Map<String, dynamic>> queue,
    int positionSeconds = 0,
    double volume = 0.5,
  }) async {
    return await repository.syncPlayerState(
      trackId: trackId,
      queue: queue,
      positionSeconds: positionSeconds,
      volume: volume,
    );
  }
}
