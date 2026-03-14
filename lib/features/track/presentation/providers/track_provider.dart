import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/domain/entities/track.dart';
import 'track_dependency_providers.dart';

final trackDetailsProvider = FutureProvider.family<Track, String>((ref, trackId) async {
  final getTrackDetails = ref.watch(getTrackDetailsUseCaseProvider);
  return await getTrackDetails.call(trackId);
});
