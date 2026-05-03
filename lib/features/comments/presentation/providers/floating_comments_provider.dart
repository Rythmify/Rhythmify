import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'comment_di_providers.dart';

/// A Riverpod [FutureProvider] that fetches and caches the floating comments map for a track.
///
/// The state managed is a [Future] resolving to a mapping of timestamp seconds
/// to a record containing the user's profile picture URL and comment text.
/// This allows O(1) synchronous lookups during audio waveform rendering.
/// Side effect: Triggers a network request when first watched for a specific `trackId`.
final floatingCommentsProvider =
    FutureProvider.family<Map<int, ({String? pfp, String text})>, String>((
      ref,
      trackId,
    ) async {
      final getFloatingComments = ref.watch(getFloatingCommentsProvider);
      return getFloatingComments(trackId);
    });
