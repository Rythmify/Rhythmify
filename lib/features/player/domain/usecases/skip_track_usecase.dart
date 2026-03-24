import '../repositories/audio_repository.dart';

/// Intent: Moves to the next track in the queue.
class SkipToNextUseCase {
  final AudioRepository repository;
  SkipToNextUseCase(this.repository);

  Future<void> call() async {
    return await repository.skipToNext();
  }
}

/// Intent: Moves to the previous track or restarts the current track.
class SkipToPreviousUseCase {
  final AudioRepository repository;
  SkipToPreviousUseCase(this.repository);

  Future<void> call() async {
    return await repository.skipToPrevious();
  }
}
