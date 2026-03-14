import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/track_local_data_source.dart';
import '../../data/repositories/mock_track_repository_impl.dart';
import '../../domain/repositories/track_repository.dart';
import '../../domain/usecases/get_track_details.dart';
import '../../domain/usecases/get_track_summary.dart';
import '../../domain/usecases/toggle_like.dart';
import '../../domain/usecases/toggle_repost.dart';
import '../../domain/usecases/record_play.dart';

// ============================================
//  --- Data Source & Repository Providers ---
// ============================================

/// Provides the local JSON reader
final trackLocalDataSourceProvider = Provider<TrackLocalDataSource>((ref) {
  return TrackLocalDataSourceImpl();
});

/// Provides the Repository. 
final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  final localDataSource = ref.watch(trackLocalDataSourceProvider);
  return MockTrackRepositoryImpl(localDataSource);
});

// ============================================
//  --- Use Case Providers (Fetching Data) ---
// ============================================

final getTrackDetailsUseCaseProvider = Provider<GetTrackDetails>((ref) {
  return GetTrackDetails(ref.watch(trackRepositoryProvider));
});

final getTrackSummaryUseCaseProvider = Provider<GetTrackSummary>((ref) {
  return GetTrackSummary(ref.watch(trackRepositoryProvider));
});

// ========================================
//  --- Use Case Providers (Mutations) ---
// ========================================

final toggleLikeUseCaseProvider = Provider<ToggleLike>((ref) {
  return ToggleLike(ref.watch(trackRepositoryProvider));
});

final toggleRepostUseCaseProvider = Provider<ToggleRepost>((ref) {
  return ToggleRepost(ref.watch(trackRepositoryProvider));
});

final recordPlayUseCaseProvider = Provider<RecordPlay>((ref) {
  return RecordPlay(ref.watch(trackRepositoryProvider));
});