import '../repositories/track_repository.dart';

/// [GetWaveform] is a use case used to retrieve audio peak data for visualization.
///
/// It communicates with the [TrackRepository] to get a list of doubles
/// representing the track's waveform amplitude.
class GetWaveform {
  final TrackRepository repository;

  GetWaveform(this.repository);

  /// Fetches the waveform peaks for the specified [trackId].
  Future<List<double>> call(String trackId) async {
    return await repository.getWaveform(trackId);
  }
}
