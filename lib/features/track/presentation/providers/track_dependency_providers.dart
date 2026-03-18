import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/track_local_data_source.dart';
import '../../data/datasources/track_remote_data_source.dart';
import '../../data/repositories/mock_track_repository_impl.dart';
import '../../data/repositories/track_repository_impl.dart';
import '../../domain/repositories/track_repository.dart';
import '../../domain/usecases/get_track_details.dart';
import '../../domain/usecases/get_waveform.dart';
import '../../domain/usecases/get_tags.dart';
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

/// Provides the Remote API data source
final trackRemoteDataSourceProvider = Provider<TrackRemoteDataSource>((ref) {
  return TrackRemoteDataSourceImpl(apiClient);
});

/// Toggle this to switch between Mock and Real API
const bool _useMock = true;

/// Provides the Repository. 
final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  if (_useMock) {
    final localDataSource = ref.watch(trackLocalDataSourceProvider);
    return MockTrackRepositoryImpl(localDataSource);
  } else {
    final remoteDataSource = ref.watch(trackRemoteDataSourceProvider);
    return TrackRepositoryImpl(remoteDataSource);
  }
});

// ============================================
//  --- Use Case Providers (Fetching Data) ---
// ============================================

final getTrackDetailsUseCaseProvider = Provider<GetTrackDetails>((ref) {
  return GetTrackDetails(ref.watch(trackRepositoryProvider));
});

final getWaveformUseCaseProvider = Provider<GetWaveform>((ref) {
  return GetWaveform(ref.watch(trackRepositoryProvider));
});

final getTagsUseCaseProvider = Provider<GetTags>((ref) {
  return GetTags(ref.watch(trackRepositoryProvider));
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