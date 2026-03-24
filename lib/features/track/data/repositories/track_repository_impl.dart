import '../../../../core/domain/entities/track.dart';
import '../../../../core/data/models/track_dto.dart';
import '../../domain/repositories/track_repository.dart';
import '../datasources/track_remote_data_source.dart';

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
    return list.map((json) => TrackDto.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<double>> getWaveform(String trackId) async {
    final response = await remoteDataSource.getWaveform(trackId);
    final List<dynamic> peaks = response['data']['peaks'];
    return peaks.map((p) => (p as num).toDouble()).toList();
  }

  @override
  Future<Map<String, String>> getTags() async {
    final response = await remoteDataSource.getTags();
    final List<dynamic> items = response['data']['items'];
    return {
      for (var item in items)
        item['id'] as String: item['name'] as String
    };
  }

  @override
  Future<void> toggleLike(String id, bool isCurrentlyLiked) async {
    // Assuming POST /tracks/{id}/like
    // await remoteDataSource.client.dio.post('/tracks/$id/like');
  }

  @override
  Future<void> toggleRepost(String id, bool isCurrentlyReposted) async {
    // Assuming POST /tracks/{id}/repost
  }

  @override
  Future<void> recordPlay(String id) async {
    // Assuming POST /tracks/{id}/play
  }
}
