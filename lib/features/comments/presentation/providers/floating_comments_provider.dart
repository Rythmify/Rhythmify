import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'comment_di_providers.dart';

/// A provider that fetches and caches the floating comments map for a track.
/// The map key is the timestamp in seconds, and the value is a Record containing pfp and text.
final floatingCommentsProvider =
    FutureProvider.family<Map<int, ({String? pfp, String text})>, String>((
      ref,
      trackId,
    ) async {
      final getFloatingComments = ref.watch(getFloatingCommentsProvider);
      return getFloatingComments(trackId); // Now returns the Record Map
    });
