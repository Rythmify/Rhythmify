import '../repositories/audio_repository.dart';

/// Intent: Moves the playback head to a specified [Duration].
///
/// This use case allows seeking within the current track.
class SeekPositionUseCase {
  final AudioRepository repository;
  SeekPositionUseCase(this.repository);

  Future<void> call(Duration position) async {
    return await repository.seek(position);
  }
}
