import '../../../../core/domain/entities/track.dart';
import '../../../../core/data/models/track_dto.dart';
import '../../domain/repositories/track_repository.dart';
import '../datasources/track_remote_data_source.dart';

/// [TrackRepositoryImpl] is the concrete implementation of [TrackRepository].
///
/// It coordinates data retrieval and mutation operations by delegating to
/// the [TrackRemoteDataSource]. It is responsible for mapping raw data
/// (DTOs) from the data source into domain entities ([Track]).
class TrackRepositoryImpl implements TrackRepository {
  final TrackRemoteDataSource remoteDataSource;

  TrackRepositoryImpl(this.remoteDataSource);

  @override
  Future<Track> getTrackDetails(String id) async {
    final json = await remoteDataSource.getTrackDetails(id);
    return TrackDto.fromJson(json);
  }

  @override
  Future<List<Track>> getTracks() async {
    final list = await remoteDataSource.getTracks();
    return list
        .map((json) => TrackDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<double>> getWaveform(String trackId) async {
    final response = await remoteDataSource.getWaveform(trackId);
    
    List<dynamic> peaks = [];
    if (response.containsKey('data') && response['data'] is Map && response['data'].containsKey('peaks')) {
      peaks = response['data']['peaks'];
    } else if (response.containsKey('peaks')) {
      peaks = response['peaks'];
    }
    
    return peaks.map((p) => (p as num).toDouble()).toList();
  }

  @override
  Future<Map<String, String>> getTags() async {
    final response = await remoteDataSource.getTags();
    final List<dynamic> items = response['data']['items'];
    return {
      for (var item in items) item['id'] as String: item['name'] as String,
    };
  }

  @override
  Future<void> toggleLike(String id, bool isCurrentlyLiked) async {
    // Implementation for remote like toggle
  }

  @override
  Future<void> toggleRepost(String id, bool isCurrentlyReposted) async {
    // Implementation for remote repost toggle
  }

  @override
  Future<void> recordPlay(String id) async {
    // Implementation for remote play recording
  }
}
