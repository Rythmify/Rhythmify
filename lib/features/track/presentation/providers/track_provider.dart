import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import 'track_dependency_providers.dart';

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
  return await getTrackDetails.call(trackId);
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
