import '../../../../core/domain/entities/track.dart';
import '../../../../core/domain/entities/track_summary.dart';
import '../../../../core/data/models/track_dto.dart';
import '../../../../core/data/models/track_summary_dto.dart';
import '../../domain/repositories/track_repository.dart';
import '../datasources/track_local_data_source.dart';

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
      orElse: () => throw Exception('Track with ID $id not found in mock data'),
    );
    
    return TrackDto.fromJson(trackJson);
  }

  @override
  Future<TrackSummary> getTrackSummary(String id) async {
    final rawData = await localDataSource.getSummaryTracks();
    
    final summaryJson = rawData.firstWhere(
      (json) => json['id'] == id,
      orElse: () => throw Exception('TrackSummary with ID $id not found'),
    );

    return TrackSummaryDto.fromJson(summaryJson);
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

}