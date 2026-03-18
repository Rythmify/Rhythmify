import '../repositories/track_repository.dart';

class RecordPlay {
  final TrackRepository repository;

  RecordPlay(this.repository);

  Future<void> call(String id) async {
    if (id.isEmpty) return;
    await repository.recordPlay(id);
  }
}