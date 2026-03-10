import '../../../../core/domain/entities/track.dart';
import '../../../../core/domain/entities/track_summary.dart';
import '../../domain/repositories/track_repository.dart';
import '../datasources/track_local_data_source.dart';
import '../models/track_dto.dart';
import '../models/track_summary_dto.dart';

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

  @override
  Future<List<TrackSummary>> searchTracks(String query) async {
    final rawData = await localDataSource.getSummaryTracks();
    final allSummaries = rawData.map((json) => TrackSummaryDto.fromJson(json)).toList();
    
    final lowerQuery = query.toLowerCase();
    return allSummaries.where((track) {
      return track.title.toLowerCase().contains(lowerQuery) || 
             track.artist.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<TrackSummary>> getTracksByTag(String tag) async {
    final rawData = await localDataSource.getSummaryTracks();
    final summaries = rawData.map((json) => TrackSummaryDto.fromJson(json)).toList();
    
    summaries.shuffle();
    return summaries.take(3).toList(); 
  }

  @override
  Future<List<TrackSummary>> getTracksByArtist(String artistId) async {
    final rawData = await localDataSource.getSummaryTracks();
    final allSummaries = rawData.map((json) => TrackSummaryDto.fromJson(json)).toList();
    return allSummaries.where((track) => track.artistId == artistId).toList();
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

  // =======================
  //  --- For Home Page ---
  // =======================

  @override
  Future<List<TrackSummary>> getTrendingTracks() async {
    final rawData = await localDataSource.getSummaryTracks();
    return rawData.map((json) => TrackSummaryDto.fromJson(json)).toList();
  }

  @override
  Future<List<TrackSummary>> getTrendingTracksByGenre(String genre) async {
    final summaries = await getTrendingTracks();
    summaries.shuffle();
    return summaries;
  }

  @override
  Future<TrackSummary> getHotTrackForYou() async {
    final summaries = await getTrendingTracks();
    return summaries.first; 
  }
}