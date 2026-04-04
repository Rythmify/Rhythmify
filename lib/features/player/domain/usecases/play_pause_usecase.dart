import '../repositories/audio_repository.dart';

/// Intent: Resumes audio playback.
class PlayTrackUseCase {
  final AudioRepository repository;
  PlayTrackUseCase(this.repository);

  Future<void> call() async {
    return await repository.play();
  }
}

/// Intent: Pauses the current audio playback.
class PauseTrackUseCase {
  final AudioRepository repository;
  PauseTrackUseCase(this.repository);

  Future<void> call() async {
    return await repository.pause();
  }
}
