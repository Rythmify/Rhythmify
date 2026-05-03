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

/// Intent: Jumps to a specific index in the current native queue.
class SkipToIndexUseCase {
  final AudioRepository repository;
  SkipToIndexUseCase(this.repository);

  Future<void> call(int index) async {
    return await repository.skipToIndex(index);
  }
}
