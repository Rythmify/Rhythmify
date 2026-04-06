import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'comment_di_providers.dart';

/// A provider that fetches and caches the floating comments map for a track.
/// The map key is the timestamp in seconds, and the value is the user's PFP URL.
final floatingCommentsProvider =
    FutureProvider.family<Map<int, String>, String>((ref, trackId) async {
      final getFloatingComments = ref.watch(getFloatingCommentsProvider);
      return getFloatingComments(trackId);
    });
