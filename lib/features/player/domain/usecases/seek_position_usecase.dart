import '../repositories/audio_repository.dart';

class SeekPositionUseCase {
  final AudioRepository repository;
  SeekPositionUseCase(this.repository);

  Future<void> call(Duration position) async {
    return await repository.seek(position);
  }
}