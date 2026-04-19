import '../../../../core/domain/entities/track.dart';
import '../../../../core/data/models/track_dto.dart';
import '../../domain/repositories/track_repository.dart';
import '../../domain/entities/fan_leaderboard.dart';
import '../datasources/track_local_data_source.dart';

/// [MockTrackRepositoryImpl] provides a simulated implementation of [TrackRepository].
///
/// This implementation relies on [TrackLocalDataSource] to fetch data from
/// local JSON assets, allowing for offline development and testing of the
/// track feature without needing a live backend.
class MockTrackRepositoryImpl implements TrackRepository {
  final TrackLocalDataSource localDataSource;

  MockTrackRepositoryImpl(this.localDataSource);

  // ========================
  //   --- Fetching Data ---
  // ========================

  @override
  Future<Track> getTrackDetails(String id) async {
    final rawData = await localDataSource.getFullTracks();

    final trackJson = rawData.firstWhere(
      (json) => json['id'] == id,
      orElse: () {
        if (id == "e5f6a7b8-c9d0-1234-efab-567890abcdef") {
          return {
            "data": {
              "id": "e5f6a7b8-c9d0-1234-efab-567890abcdef",
              "title": "Summer Vibes",
              "description": "A chill electronic track",
              "genre": "Electronic",
              "tags": [
                "aaa11111-bbbb-cccc-dddd-eeeeeeeeeeee",
                "bbb22222-cccc-dddd-eeee-ffffffffffff",
              ],
              "duration": 210,
              "audio_url": "assets/audio/Track_audio_1.mp3",
              "stream_url":
                  "https://cdn.rythmify.com/tracks/e5f6a7b8/stream.mp3",
              "artists": "Ahmed Sami, DJ Karim",
            },
          };
        }
        throw Exception('Track with ID $id not found in mock data');
      },
    );

    return TrackDto.fromJson(trackJson);
  }

  @override
  Future<List<Track>> getTracks() async {
    final rawData = await localDataSource.getSummaryTracks();
    return rawData
        .map((json) => TrackDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<double>> getWaveform(String trackId) async {
    final response = await localDataSource.getWaveform(trackId);
    final List<dynamic> peaks = response['data']['peaks'];
    return peaks.map((p) => (p as num).toDouble()).toList();
  }

  @override
  Future<Map<String, String>> getTags() async {
    final response = await localDataSource.getTags();
    final List<dynamic> items = response['data']['items'];
    return {
      for (var item in items) item['id'] as String: item['name'] as String,
    };
  }

  @override
  Future<FanLeaderboard> getFanLeaderboard(String trackId, String period) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return FanLeaderboard(
      period: period,
      items: [],
    );
  }

  // ================================
  //   --- Mutations (Simulated) ---
  // ================================

  @override
  Future<void> toggleLike(String id, bool isCurrentlyLiked) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> toggleRepost(String id, bool isCurrentlyReposted) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> recordPlay(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> updateTrack(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> deleteTrack(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
