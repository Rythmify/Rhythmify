import 'package:rythmify/features/messaging/domain/entities/shared_embed.dart';
import 'package:rythmify/features/messaging/domain/repositories/messaging_repository.dart';

/// Use case for retrieving details of a track by its ID.
///
/// Delegates to [MessagingRepository.getTrack].
/// Used in [getTrackDetailsProvider] to fetch track name, artist, and thumbnail
/// for display in [MessageBubble].
class GetTrackDetailsUsecase {
  final MessagingRepository repo;

  GetTrackDetailsUsecase({required this.repo});

  Future<SharedEmbed> call(String trackId) async {
    return repo.getTrack(trackId);
  }
}
