import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import 'track_dependency_providers.dart';
import '../../../profile/data/datasources/profile_remote_datasource_impl.dart';
import '../../../profile/data/repositories/profile_repository_impl.dart';
import '../../../profile/domain/usecases/get_profile_usecase.dart';
import '../../../../core/network/api_client.dart';

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  final datasource = ProfileRemoteDatasourceImpl(client: apiClient);
  final repository = ProfileRepositoryImpl(remoteDatasource: datasource);
  return GetProfileUseCase(repository);
});

/// [trackDetailsProvider] manages the state of a specific track's detailed information.
///
/// It uses [getTrackDetailsUseCaseProvider] to fetch data.
/// State: [AsyncData] contains the [Track] details, [AsyncLoading] represents the
/// fetching process, and [AsyncError] captures any failure during retrieval.
/// Layer: Presentation
/// Depends on [getTrackDetailsUseCaseProvider].
final trackDetailsProvider = FutureProvider.family<Track, String>((
  ref,
  trackId,
) async {
  final getTrackDetails = ref.watch(getTrackDetailsUseCaseProvider);
  final getProfile = ref.watch(getProfileUseCaseProvider);

  final track = await getTrackDetails.call(trackId);

  // Fetch profile to populate additional artist details
  final profileResult = await getProfile.call(userId: track.userId);

  return profileResult.fold(
    (failure) => track,
    (profile) => track.copyWith(
      artist: profile.displayName.isNotEmpty
          ? profile.displayName
          : track.artist,
      artistPfp: profile.avatarUrl,
      artistCity: profile.city,
      artistCountry: profile.country,
    ),
  );
});

/// [allTracksProvider] manages the state of the complete track list.
///
/// It fetches a collection of tracks using [getTracksUseCaseProvider].
/// State: [AsyncData] holds the [List] of [Track] entities, [AsyncLoading]
/// is shown during the initial load, and [AsyncError] indicates a problem.
/// Layer: Presentation
/// Depends on [getTracksUseCaseProvider].
final allTracksProvider = FutureProvider<List<Track>>((ref) async {
  final getTracks = ref.watch(getTracksUseCaseProvider);
  return await getTracks.call();
});
