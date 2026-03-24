import '../repositories/audio_repository.dart';

class PlayTrackUseCase {
  final AudioRepository repository;
  PlayTrackUseCase(this.repository);

  Future<void> call() async {
    return await repository.play();
  }
}

class PauseTrackUseCase {
  final AudioRepository repository;
  PauseTrackUseCase(this.repository);

  Future<void> call() async {
    return await repository.pause();
  }
}
