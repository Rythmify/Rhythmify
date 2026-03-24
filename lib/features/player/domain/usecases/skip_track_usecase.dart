import '../repositories/audio_repository.dart';

class SkipToNextUseCase {
  final AudioRepository repository;
  SkipToNextUseCase(this.repository);

  Future<void> call() async {
    return await repository.skipToNext();
  }
}

class SkipToPreviousUseCase {
  final AudioRepository repository;
  SkipToPreviousUseCase(this.repository);

  Future<void> call() async {
    return await repository.skipToPrevious();
  }
}
