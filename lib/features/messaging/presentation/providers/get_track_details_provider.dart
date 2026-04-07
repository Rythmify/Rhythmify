import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/usecases/get_track_details_usecase.dart';
import 'package:rythmify/features/messaging/presentation/providers/repository_provider.dart';

/// A [FutureProvider] that fetches details of a track by its [trackId].
///
/// Returns a [SharedEmbed] with the track title, artist name, and thumbnail URL.
/// Used in [MessageBubble] to display embed details for track messages.
/// Cached by Riverpod — multiple bubbles with the same [trackId] share one request.

final getTrackDetailsProvider = FutureProvider.family<SharedEmbed, String>((
  ref,
  trackId,
) async {
  final uCase = GetTrackDetailsUsecase(repo: ref.read(repositoryprovider));
  final msg = await uCase(trackId);
  return msg;
});
