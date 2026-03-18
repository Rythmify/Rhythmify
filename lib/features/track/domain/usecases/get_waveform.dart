import '../repositories/track_repository.dart';

class GetWaveform {
  final TrackRepository repository;

  GetWaveform(this.repository);

  Future<List<double>> call(String trackId) async {
    return await repository.getWaveform(trackId);
  }
}
