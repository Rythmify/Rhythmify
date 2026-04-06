import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/track_local_data_source.dart';
import '../../data/datasources/track_remote_data_source.dart';
import '../../data/repositories/mock_track_repository_impl.dart';
import '../../data/repositories/track_repository_impl.dart';
import '../../domain/repositories/track_repository.dart';
import '../../domain/usecases/get_track_details.dart';
import '../../domain/usecases/get_tracks.dart';
import '../../domain/usecases/get_waveform.dart';
import '../../domain/usecases/get_tags.dart';
import '../../domain/usecases/toggle_like.dart';
import '../../domain/usecases/toggle_repost.dart';
import '../../domain/usecases/record_play.dart';

// ====================
//  --- The Switch ---
// ====================

const bool _useMock = false;

// ============================================
//  --- Data Source & Repository Providers ---
// ============================================

/// [trackLocalDataSourceProvider] provides an instance of [TrackLocalDataSource].
///
/// Manages the [TrackLocalDataSource] implementation for fetching mock data.
/// Layer: Data
final trackLocalDataSourceProvider = Provider<TrackLocalDataSource>((ref) {
  return TrackLocalDataSourceImpl();
});

/// [trackRemoteDataSourceProvider] provides an instance of [TrackRemoteDataSource].
///
/// Manages the remote API interaction using the global [apiClient].
/// Layer: Data
final trackRemoteDataSourceProvider = Provider<TrackRemoteDataSource>((ref) {
  return TrackRemoteDataSourceImpl(apiClient);
});

/// [trackRepositoryProvider] provides the [TrackRepository] implementation.
///
/// Depending on [_useMock], it returns either [MockTrackRepositoryImpl] or [TrackRepositoryImpl].
/// Layer: Data/Domain Interface
/// Depends on [trackLocalDataSourceProvider] and [trackRemoteDataSourceProvider].
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

/// Provides the [GetTrackDetails] use case.
///
/// Layer: Domain
/// Depends on [trackRepositoryProvider].
final getTrackDetailsUseCaseProvider = Provider<GetTrackDetails>((ref) {
  return GetTrackDetails(ref.watch(trackRepositoryProvider));
});

/// Provides the [GetTracks] use case.
///
/// Layer: Domain
/// Depends on [trackRepositoryProvider].
final getTracksUseCaseProvider = Provider<GetTracks>((ref) {
  return GetTracks(ref.watch(trackRepositoryProvider));
});

/// Provides the [GetWaveform] use case.
///
/// Layer: Domain
/// Depends on [trackRepositoryProvider].
final getWaveformUseCaseProvider = Provider<GetWaveform>((ref) {
  return GetWaveform(ref.watch(trackRepositoryProvider));
});

/// Provides the [GetTags] use case.
///
/// Layer: Domain
/// Depends on [trackRepositoryProvider].
final getTagsUseCaseProvider = Provider<GetTags>((ref) {
  return GetTags(ref.watch(trackRepositoryProvider));
});

// ========================================
//  --- Use Case Providers (Mutations) ---
// ========================================

/// Provides the [ToggleLike] use case.
///
/// Layer: Domain
/// Depends on [trackRepositoryProvider].
final toggleLikeUseCaseProvider = Provider<ToggleLike>((ref) {
  return ToggleLike(ref.watch(trackRepositoryProvider));
});

/// Provides the [ToggleRepost] use case.
///
/// Layer: Domain
/// Depends on [trackRepositoryProvider].
final toggleRepostUseCaseProvider = Provider<ToggleRepost>((ref) {
  return ToggleRepost(ref.watch(trackRepositoryProvider));
});

/// Provides the [RecordPlay] use case.
///
/// Layer: Domain
/// Depends on [trackRepositoryProvider].
final recordPlayUseCaseProvider = Provider<RecordPlay>((ref) {
  return RecordPlay(ref.watch(trackRepositoryProvider));
});