import '../repositories/playback_repository.dart';

class InitiatePlaybackUseCase {
  final PlaybackRepository _repository;

  InitiatePlaybackUseCase(this._repository);

  Future<String> call(String trackId) {
    return _repository.initiatePlayback(trackId);
  }
}
